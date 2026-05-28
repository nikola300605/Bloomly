"""
AI scan service — plant identification and health diagnosis.

Currently returns stub responses. To wire up a real provider:
1. Add the provider SDK to requirements.txt (e.g. openai, plant-id, google-cloud-vision)
2. Replace the stub blocks below with real API calls
3. Map the provider response onto ScanResultOut / ScanCandidate / ScanActionStep
"""
import uuid
from datetime import datetime
from typing import Optional

import httpx

from app.config import settings
from app.models.scan import ScanResultOut, ScanCandidate, ScanActionStep

_CONFIDENCE_THRESHOLD = 0.60


async def identify_plant(image_bytes: bytes, mime_type: str = "image/jpeg") -> ScanResultOut:
    """Identify a plant species from a photo."""

    if settings.ai_service_url:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                f"{settings.ai_service_url}/identify",
                headers={"Authorization": f"Bearer {settings.ai_api_key}"},
                files={"image": ("plant.jpg", image_bytes, mime_type)},
            )
            response.raise_for_status()
            # TODO: parse provider-specific response shape here
            data = response.json()

    # --- stub response (remove once a real provider is wired) ---
    candidates = [
        ScanCandidate(name="Monstera deliciosa", confidence=0.91, description="Swiss cheese plant"),
        ScanCandidate(name="Monstera adansonii", confidence=0.07, description="Mini monstera"),
    ]
    top_confidence = candidates[0].confidence if candidates else 0.0

    return ScanResultOut(
        id=str(uuid.uuid4()),
        mode="identify",
        top_candidates=candidates,
        confidence=top_confidence,
        low_confidence=top_confidence < _CONFIDENCE_THRESHOLD,
        created_at=datetime.utcnow(),
    )


async def diagnose_plant(
    image_bytes: bytes,
    symptoms: list[str],
    plant_id: Optional[str] = None,
    mime_type: str = "image/jpeg",
) -> ScanResultOut:
    """Diagnose a plant health issue from a photo + symptom list."""

    if settings.ai_service_url:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                f"{settings.ai_service_url}/diagnose",
                headers={"Authorization": f"Bearer {settings.ai_api_key}"},
                files={"image": ("leaf.jpg", image_bytes, mime_type)},
                data={"symptoms": ",".join(symptoms)},
            )
            response.raise_for_status()
            # TODO: parse provider-specific response shape here
            data = response.json()

    # --- stub response (remove once a real provider is wired) ---
    confidence = 0.87
    return ScanResultOut(
        id=str(uuid.uuid4()),
        plant_id=plant_id,
        mode="diagnose",
        diagnosis="Overwatering",
        confidence=confidence,
        low_confidence=confidence < _CONFIDENCE_THRESHOLD,
        explanation=(
            "The yellowing and soft stems suggest the roots are staying too wet, "
            "likely due to overwatering or insufficient drainage."
        ),
        action_steps=[
            ScanActionStep(icon="💧", title="Let soil dry 1–2 inches", description="Before the next watering"),
            ScanActionStep(icon="🪨", title="Check drainage holes", description="Pot must drain freely"),
            ScanActionStep(icon="🌬", title="Increase airflow", description="Helps roots recover"),
        ],
        created_at=datetime.utcnow(),
    )
