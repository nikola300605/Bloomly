from fastapi import APIRouter, HTTPException, status
from typing import List, Optional
from pydantic import BaseModel

from app.data.plant_catalog import search_catalog, get_species

router = APIRouter()


class CatalogSpeciesOut(BaseModel):
    id: str
    common_name: str
    species: str
    emoji: str
    photo_url: Optional[str] = None
    description: Optional[str] = None
    light: str
    humidity: bool = False
    pet_safe: bool = False
    difficulty: str
    care_schedule: dict


@router.get("/", response_model=List[CatalogSpeciesOut])
async def list_catalog(q: Optional[str] = None):
    """List (or search) the built-in plant species catalog."""
    return search_catalog(q)


@router.get("/{species_id}", response_model=CatalogSpeciesOut)
async def get_catalog_species(species_id: str):
    item = get_species(species_id)
    if not item:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Species not found")
    return item
