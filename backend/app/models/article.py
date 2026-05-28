from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class ArticleCreate(BaseModel):
    title: str
    body: str
    cover_photo: Optional[str] = None
    tags: List[str] = []
    linked_plant_ids: List[str] = []


class ArticleUpdate(BaseModel):
    title: Optional[str] = None
    body: Optional[str] = None
    cover_photo: Optional[str] = None
    tags: Optional[List[str]] = None
    linked_plant_ids: Optional[List[str]] = None


class ArticleOut(BaseModel):
    id: str
    author_id: str
    title: str
    body: str
    cover_photo: Optional[str] = None
    tags: List[str] = []
    linked_plant_ids: List[str] = []
    created_at: datetime
    updated_at: Optional[datetime] = None
    like_count: int = 0
    comment_count: int = 0
    author_handle: Optional[str] = None
    author_avatar: Optional[str] = None
    is_liked: bool = False
    is_saved: bool = False


class CommentCreate(BaseModel):
    body: str


class CommentOut(BaseModel):
    id: str
    article_id: str
    author_id: str
    author_handle: str
    author_avatar: Optional[str] = None
    body: str
    created_at: datetime
