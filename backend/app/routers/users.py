from fastapi import APIRouter, Depends, HTTPException, status
from bson import ObjectId
from datetime import datetime

from app.database import get_database
from app.models.user import UserOut, UserUpdate
from app.dependencies import get_current_user_id

router = APIRouter()


def _user_to_out(doc: dict) -> UserOut:
    doc = dict(doc)
    doc["id"] = str(doc.pop("_id"))
    doc.pop("password_hash", None)
    return UserOut(**doc)


@router.get("/me", response_model=UserOut)
async def get_me(user_id: str = Depends(get_current_user_id)):
    db = get_database()
    user = await db.users.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return _user_to_out(user)


@router.patch("/me", response_model=UserOut)
async def update_me(updates: UserUpdate, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    update_data = updates.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No fields to update")
    await db.users.update_one({"_id": ObjectId(user_id)}, {"$set": update_data})
    user = await db.users.find_one({"_id": ObjectId(user_id)})
    return _user_to_out(user)


@router.get("/me/saved-articles")
async def get_saved_articles(user_id: str = Depends(get_current_user_id)):
    db = get_database()
    saved = await db.saved_articles.find({"user_id": user_id}).sort("saved_at", -1).to_list(length=200)
    ids = [ObjectId(s["article_id"]) for s in saved]
    articles = await db.articles.find({"_id": {"$in": ids}}).to_list(length=200)
    return [{"id": str(a.pop("_id")), **a} for a in articles]
