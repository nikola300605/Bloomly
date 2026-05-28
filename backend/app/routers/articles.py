from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from bson import ObjectId
from datetime import datetime

from app.database import get_database
from app.models.article import ArticleCreate, ArticleUpdate, ArticleOut, CommentCreate, CommentOut
from app.dependencies import get_current_user_id

router = APIRouter()


async def _enrich_article(db, doc: dict, caller_user_id: Optional[str] = None) -> ArticleOut:
    doc = dict(doc)
    article_id = str(doc["_id"])
    doc["id"] = article_id
    del doc["_id"]

    like_count = await db.likes.count_documents({"article_id": article_id})
    comment_count = await db.comments.count_documents({"article_id": article_id})
    is_liked = False
    is_saved = False

    if caller_user_id:
        is_liked = bool(await db.likes.find_one({"article_id": article_id, "user_id": caller_user_id}))
        is_saved = bool(await db.saved_articles.find_one({"article_id": article_id, "user_id": caller_user_id}))

    author = await db.users.find_one({"_id": ObjectId(doc["author_id"])})
    return ArticleOut(
        **doc,
        like_count=like_count,
        comment_count=comment_count,
        is_liked=is_liked,
        is_saved=is_saved,
        author_handle=author["handle"] if author else None,
        author_avatar=author.get("avatar") if author else None,
    )


@router.get("/", response_model=List[ArticleOut])
async def list_articles(
    filter: Optional[str] = None,
    skip: int = 0,
    limit: int = 20,
    user_id: Optional[str] = Depends(get_current_user_id),
):
    db = get_database()
    query: dict = {}
    if filter == "questions":
        query["tags"] = {"$in": ["question", "ask"]}
    elif filter == "how_to":
        query["tags"] = {"$in": ["how-to", "howto"]}

    docs = await db.articles.find(query).sort("created_at", -1).skip(skip).limit(limit).to_list(length=limit)
    return [await _enrich_article(db, doc, user_id) for doc in docs]


@router.post("/", response_model=ArticleOut, status_code=status.HTTP_201_CREATED)
async def create_article(article: ArticleCreate, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    doc = article.model_dump()
    doc["author_id"] = user_id
    doc["created_at"] = datetime.utcnow()
    result = await db.articles.insert_one(doc)
    created = await db.articles.find_one({"_id": result.inserted_id})
    return await _enrich_article(db, created, user_id)


@router.get("/{article_id}", response_model=ArticleOut)
async def get_article(article_id: str, user_id: Optional[str] = Depends(get_current_user_id)):
    db = get_database()
    doc = await db.articles.find_one({"_id": ObjectId(article_id)})
    if not doc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found")
    return await _enrich_article(db, doc, user_id)


@router.patch("/{article_id}", response_model=ArticleOut)
async def update_article(article_id: str, updates: ArticleUpdate, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    update_data = updates.model_dump(exclude_unset=True)
    update_data["updated_at"] = datetime.utcnow()
    result = await db.articles.update_one(
        {"_id": ObjectId(article_id), "author_id": user_id},
        {"$set": update_data},
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found or not owned by you")
    doc = await db.articles.find_one({"_id": ObjectId(article_id)})
    return await _enrich_article(db, doc, user_id)


@router.delete("/{article_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_article(article_id: str, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    result = await db.articles.delete_one({"_id": ObjectId(article_id), "author_id": user_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Article not found or not owned by you")


@router.post("/{article_id}/like")
async def toggle_like(article_id: str, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    existing = await db.likes.find_one({"article_id": article_id, "user_id": user_id})
    if existing:
        await db.likes.delete_one({"_id": existing["_id"]})
        return {"liked": False}
    await db.likes.insert_one({"article_id": article_id, "user_id": user_id})
    return {"liked": True}


@router.post("/{article_id}/save")
async def toggle_save(article_id: str, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    existing = await db.saved_articles.find_one({"article_id": article_id, "user_id": user_id})
    if existing:
        await db.saved_articles.delete_one({"_id": existing["_id"]})
        return {"saved": False}
    await db.saved_articles.insert_one(
        {"article_id": article_id, "user_id": user_id, "saved_at": datetime.utcnow()}
    )
    return {"saved": True}


@router.get("/{article_id}/comments", response_model=List[CommentOut])
async def list_comments(article_id: str):
    db = get_database()
    docs = await db.comments.find({"article_id": article_id}).sort("created_at", 1).to_list(length=200)
    result = []
    for c in docs:
        author = await db.users.find_one({"_id": ObjectId(c["author_id"])})
        result.append(CommentOut(
            id=str(c["_id"]),
            article_id=c["article_id"],
            author_id=c["author_id"],
            author_handle=author["handle"] if author else "unknown",
            author_avatar=author.get("avatar") if author else None,
            body=c["body"],
            created_at=c["created_at"],
        ))
    return result


@router.post("/{article_id}/comments", response_model=CommentOut, status_code=status.HTTP_201_CREATED)
async def add_comment(article_id: str, comment: CommentCreate, user_id: str = Depends(get_current_user_id)):
    db = get_database()
    doc = {
        "article_id": article_id,
        "author_id": user_id,
        "body": comment.body,
        "created_at": datetime.utcnow(),
    }
    result = await db.comments.insert_one(doc)
    author = await db.users.find_one({"_id": ObjectId(user_id)})
    return CommentOut(
        id=str(result.inserted_id),
        article_id=article_id,
        author_id=user_id,
        author_handle=author["handle"] if author else "unknown",
        author_avatar=author.get("avatar") if author else None,
        body=comment.body,
        created_at=doc["created_at"],
    )
