from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class ScanCandidate(BaseModel):
    name: str
    confidence: float
    description: Optional[str] = None
    photo_url: Optional[str] = None


class ScanActionStep(BaseModel):
    icon: str
    title: str
    description: str


class ScanResultOut(BaseModel):
    id: str
    plant_id: Optional[str] = None
    mode: str  # "identify" | "diagnose"
    top_candidates: List[ScanCandidate] = []
    diagnosis: Optional[str] = None
    confidence: Optional[float] = None
    low_confidence: bool = False
    explanation: Optional[str] = None
    action_steps: List[ScanActionStep] = []
    photo_url: Optional[str] = None
    created_at: datetime
