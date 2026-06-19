from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from bson import ObjectId
from datetime import datetime

from app.database import get_database
from app.models.plant import PlantCreate, PlantUpdate, PlantOut, CareBadge, HealthLogEntryCreate
from app.models.care_task import CareTaskOut, CompleteTaskRequest, SnoozeTaskRequest
from app.services.care_scheduler import compute_care_badge, get_care_tasks
from app.dependencies import get_current_user_id

router = APIRouter()


def _plant_to_out(doc: dict) -> PlantOut:
    doc = dict(doc)
    doc["id"] = str(doc.pop("_id"))
    badge_dict = compute_care_badge(doc.get("care_schedule", {}))
    badge = CareBadge(**badge_dict) if badge_dict else None
    return PlantOut(**doc, next_care_badge=badge)


@router.get("/", response_model=List[PlantOut])
async def list_plants(user_id: str = Depends(get_current_user_id)):
    db = get_database()
    docs = await db.plants.find({"owner_id": user_id}).to_list(length=200)
    return [_plant_to_out(d) for d in docs]


@router.post("/", response_model=PlantOut, status_code=status.HTTP_201_CREATED)
async def create_plant(plant: PlantCreate, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    doc = plant.model_dump()
    doc["owner_id"] = user_id
    doc["health_log"] = []
    doc["notes"] = None
    doc["created_at"] = datetime.utcnow()
    result = await db.plants.insert_one(doc)
    created = await db.plants.find_one({"_id": result.inserted_id})
    return _plant_to_out(created)


@router.get("/care/tasks", response_model=List[CareTaskOut])
async def list_care_tasks(user_id: str = Depends(get_current_user_id)):
    """Return all upcoming + overdue care tasks across the user's plants, sorted by due date."""
    db = get_database()
    docs = await db.plants.find({"owner_id": user_id}).to_list(length=200)
    tasks: List[CareTaskOut] = []
    for doc in docs:
        tasks.extend(get_care_tasks(doc))
    tasks.sort(key=lambda t: t.due_at)
    return tasks


@router.get("/{plant_id}", response_model=PlantOut)
async def get_plant(plant_id: str, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    doc = await db.plants.find_one({"_id": ObjectId(plant_id), "owner_id": user_id})
    if not doc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plant not found")
    return _plant_to_out(doc)


@router.patch("/{plant_id}", response_model=PlantOut)
async def update_plant(plant_id: str, updates: PlantUpdate, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    update_data = updates.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No fields to update")
    await db.plants.update_one(
        {"_id": ObjectId(plant_id), "owner_id": user_id},
        {"$set": update_data},
    )
    doc = await db.plants.find_one({"_id": ObjectId(plant_id), "owner_id": user_id})
    if not doc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plant not found")
    return _plant_to_out(doc)


@router.delete("/{plant_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_plant(plant_id: str, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    result = await db.plants.delete_one({"_id": ObjectId(plant_id), "owner_id": user_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plant not found")


@router.post("/{plant_id}/health-log", response_model=PlantOut)
async def add_health_log(plant_id: str, entry: HealthLogEntryCreate, user_id: str = Depends(get_current_user_id)):
    """Append an entry to a plant's health log (e.g. saving a scan diagnosis after the fact)."""
    db = get_database()
    log_entry = entry.model_dump()
    log_entry["timestamp"] = datetime.utcnow()
    result = await db.plants.update_one(
        {"_id": ObjectId(plant_id), "owner_id": user_id},
        {"$push": {"health_log": log_entry}},
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plant not found")
    doc = await db.plants.find_one({"_id": ObjectId(plant_id), "owner_id": user_id})
    return _plant_to_out(doc)


@router.post("/{plant_id}/care/done")
async def mark_care_done(plant_id: str, req: CompleteTaskRequest, user_id: str = Depends(get_current_user_id)):
    """Mark a care task as done — resets last_done_at so next due is rescheduled."""
    db = get_database()
    now = datetime.utcnow()
    result = await db.plants.update_one(
        {"_id": ObjectId(plant_id), "owner_id": user_id},
        {"$set": {f"care_schedule.{req.kind}.last_done_at": now}},
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plant not found")
    return {"status": "ok", "last_done_at": now.isoformat()}


@router.post("/{plant_id}/care/snooze")
async def snooze_care(plant_id: str, req: SnoozeTaskRequest, user_id: str = Depends(get_current_user_id)):
    """Push a care task's due date forward by snooze_days without marking it done."""
    from datetime import timedelta
    db = get_database()
    doc = await db.plants.find_one({"_id": ObjectId(plant_id), "owner_id": user_id})
    if not doc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plant not found")

    care = doc.get("care_schedule", {}).get(req.kind, {})
    interval = care.get("interval_days", 7)
    last_done = care.get("last_done_at") or datetime.utcnow() - timedelta(days=interval)
    snoozed_last_done = last_done + timedelta(days=req.snooze_days)

    await db.plants.update_one(
        {"_id": ObjectId(plant_id)},
        {"$set": {f"care_schedule.{req.kind}.last_done_at": snoozed_last_done}},
    )
    return {"status": "snoozed", "snooze_days": req.snooze_days}
