from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException, status
from typing import Optional
from bson import ObjectId
from datetime import datetime

from app.models.scan import ScanResultOut
from app.services.ai_scan import identify_plant, diagnose_plant
from app.database import get_database
from app.dependencies import get_current_user_id

router = APIRouter()


@router.post("/identify", response_model=ScanResultOut)
async def scan_identify(
    image: UploadFile = File(...),
    _user_id: str = Depends(get_current_user_id),
):
    """Identify a plant species from a photo."""
    image_bytes = await image.read()
    return await identify_plant(image_bytes, image.content_type or "image/jpeg")


@router.post("/diagnose", response_model=ScanResultOut)
async def scan_diagnose(
    image: UploadFile = File(...),
    symptoms: str = Form(default=""),
    plant_id: Optional[str] = Form(default=None),
    user_id: str = Depends(get_current_user_id),
):
    """Diagnose a plant health issue from a photo + symptom chips."""
    image_bytes = await image.read()
    symptoms_list = [s.strip() for s in symptoms.split(",") if s.strip()]
    result = await diagnose_plant(image_bytes, symptoms_list, plant_id, image.content_type or "image/jpeg")

    if plant_id:
        db = get_database()
        log_entry = {
            "timestamp": datetime.utcnow(),
            "source": "scan",
            "diagnosis": result.diagnosis,
            "notes": result.explanation,
        }
        await db.plants.update_one(
            {"_id": ObjectId(plant_id), "owner_id": user_id},
            {"$push": {"health_log": log_entry}},
        )

    return result
