from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class CareInterval(BaseModel):
    interval_days: int
    last_done_at: Optional[datetime] = None


class CareSchedule(BaseModel):
    water: CareInterval = Field(default_factory=lambda: CareInterval(interval_days=7))
    fertilize: CareInterval = Field(default_factory=lambda: CareInterval(interval_days=30))
    rotate: Optional[CareInterval] = None
    prune: Optional[CareInterval] = None


class HealthLogEntry(BaseModel):
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    source: str  # "scan" | "manual"
    diagnosis: Optional[str] = None
    photo_url: Optional[str] = None
    notes: Optional[str] = None


class HealthLogEntryCreate(BaseModel):
    source: str = "scan"
    diagnosis: Optional[str] = None
    photo_url: Optional[str] = None
    notes: Optional[str] = None


class PlantCreate(BaseModel):
    species: str
    common_name: str
    nickname: Optional[str] = None
    location: Optional[str] = None
    photo_url: Optional[str] = None
    age_or_acquired_at: Optional[str] = None
    care_schedule: CareSchedule = Field(default_factory=CareSchedule)


class PlantUpdate(BaseModel):
    nickname: Optional[str] = None
    location: Optional[str] = None
    photo_url: Optional[str] = None
    notes: Optional[str] = None
    care_schedule: Optional[CareSchedule] = None


class CareBadge(BaseModel):
    kind: str  # "ok" | "warn" | "bad" | "info"
    label: str


class PlantOut(BaseModel):
    id: str
    owner_id: str
    species: str
    common_name: str
    nickname: Optional[str] = None
    location: Optional[str] = None
    photo_url: Optional[str] = None
    age_or_acquired_at: Optional[str] = None
    care_schedule: CareSchedule
    health_log: List[HealthLogEntry] = []
    notes: Optional[str] = None
    created_at: datetime
    next_care_badge: Optional[CareBadge] = None
