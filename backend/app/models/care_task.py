from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class CareTaskOut(BaseModel):
    id: str
    plant_id: str
    plant_name: str
    plant_photo_url: Optional[str] = None
    kind: str  # "water" | "fertilize" | "rotate" | "prune"
    due_at: datetime
    status: str = "pending"  # "pending" | "done" | "snoozed"
    completed_at: Optional[datetime] = None
    overdue_days: int = 0
    badge_kind: str = "info"  # "ok" | "warn" | "bad" | "info"
    badge_label: str = ""


class CompleteTaskRequest(BaseModel):
    kind: str


class SnoozeTaskRequest(BaseModel):
    kind: str
    snooze_days: int = 1
