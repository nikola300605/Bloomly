from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class UserCreate(BaseModel):
    name: str
    handle: str
    email: str
    avatar: Optional[str] = None
    location: Optional[str] = None
    climate_zone: Optional[str] = None


class UserOut(BaseModel):
    id: str
    name: str
    handle: str
    email: str
    avatar: Optional[str] = None
    location: Optional[str] = None
    climate_zone: Optional[str] = None
    created_at: datetime


class UserUpdate(BaseModel):
    name: Optional[str] = None
    handle: Optional[str] = None
    avatar: Optional[str] = None
    location: Optional[str] = None
    climate_zone: Optional[str] = None
