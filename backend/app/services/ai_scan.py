"""
AI scan service — plant identification and health diagnosis.

Currently returns stub responses. To wire up a real provider:
1. Add the provider SDK to requirements.txt (e.g. openai, plant-id, google-cloud-vision)
2. Replace the stub blocks below with real API calls
3. Map the provider response onto ScanResultOut / ScanCandidate / ScanActionStep
"""
import uuid
from datetime import datetime, timezone
from typing import Optional
import base64

import httpx

from app.config import settings
from app.models.scan import ScanResultOut, ScanCandidate, ScanActionStep

_CONFIDENCE_THRESHOLD = 0.60


async def identify_plant(image_bytes: bytes, mime_type: str = "image/jpeg") -> ScanResultOut:
    """Identify a plant species from a photo."""

    b64 = base64.b64encode(image_bytes).decode()

    if settings.ai_service_url:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                f"{settings.ai_service_url}/identification",
                headers={"Api-Key": settings.ai_api_key},
                params={"details": "common_names,description"},
                json={
                    "images": [f"data:{mime_type};base64,{b64}"],
                    "similar_images": True,
                }
            )
            if not response.is_success:
                raise httpx.HTTPStatusError(
                    f"Plant.id {response.status_code}: {response.text}",
                    request=response.request,
                    response=response,
                )
            data = response.json()


    suggestions = data["result"]["classification"]["suggestions"]
    candidates = [
        ScanCandidate(
            name=s["name"],
            confidence=round(s["probability"], 2),
            description=(((s.get("details") or {}).get("common_names")) or [None])[0],
        )
        for s in suggestions] 
    
    top_confidence = candidates[0].confidence if candidates else 0.0

    return ScanResultOut(
        id=str(uuid.uuid4()),
        mode="identify",
        top_candidates=candidates,
        confidence=top_confidence,
        low_confidence=top_confidence < _CONFIDENCE_THRESHOLD,
        created_at=datetime.now(timezone.utc),
    )


async def diagnose_plant(
    image_bytes: bytes,
    symptoms: list[str],
    plant_id: Optional[str] = None,
    mime_type: str = "image/jpeg",
) -> ScanResultOut:
    """Diagnose a plant health issue from a photo + symptom list."""

    b64 = base64.b64encode(image_bytes).decode()

    if settings.ai_service_url:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                f"{settings.ai_service_url}/health_assessment",
                headers={"Api-Key": settings.ai_api_key},
                params={"details": "description,treatment"},
                json={
                    "images": [f"data:{mime_type};base64,{b64}"],
                }
            )
            response.raise_for_status()
            data = response.json()

    is_happy = data["result"]["is_healthy"]["binary"]
    if is_happy:
        return ScanResultOut(
            id=str(uuid.uuid4()),
            plant_id=plant_id,
            mode="diagnose",
            diagnosis="Your plant looks healthy!",
            confidence=1.0,
            low_confidence=False,
            explanation="No signs of disease or stress were detected.",
            action_steps=[ScanActionStep(icon="✅", title="Keep it up", description="Current care routine is working well")],
            created_at=datetime.now(timezone.utc),
        )

    CATEGORY_ICONS = {
        "biological": "🌿",
        "chemical": "🧪",
        "prevention": "🛡️",
    }

    suggestion = data["result"]["disease"]["suggestions"][0]
    treatment = (suggestion.get("details") or {}).get("treatment") or {}
    action_steps = []

    for t in (treatment.get("biological") or [])[:2]:
        action_steps.append(ScanActionStep(icon=CATEGORY_ICONS["biological"], title=t, description=""))
    for t in (treatment.get("chemical") or [])[:1]:
        action_steps.append(ScanActionStep(icon=CATEGORY_ICONS["chemical"], title=t, description=""))
    for t in (treatment.get("prevention") or [])[:1]:
        action_steps.append(ScanActionStep(icon=CATEGORY_ICONS["prevention"], title=t, description=""))

    if not action_steps:
        action_steps = [ScanActionStep(icon="🔍", title="Consult a specialist", description="No treatment data available")]

    confidence = suggestion["probability"]
    return ScanResultOut(
        id=str(uuid.uuid4()),
        plant_id=plant_id,
        mode="diagnose",
        diagnosis=suggestion["name"],
        confidence=confidence,
        low_confidence=confidence < _CONFIDENCE_THRESHOLD,
        explanation=(suggestion.get("details") or {}).get("description"),
        action_steps=action_steps,
        created_at=datetime.now(timezone.utc),
    )
