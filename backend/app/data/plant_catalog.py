"""
A small built-in catalog of common houseplants with default care schedules.

Used by the "Search by name" and "Find your plant" (quiz) add-plant flows so
users can add a plant in one tap without the scan feature. Static data — always
available and never wiped by the demo seed.
"""

import json
from pathlib import Path

_DATA = Path(__file__).parent / "plants_enriched.json"

with open(_DATA, encoding="utf-8") as _f:
    _raw = json.load(_f)


def _schedule(p: dict) -> dict:
    s = {
        "water": {"interval_days": p["water_interval_days"]},
        "fertilize": {"interval_days": p["fertilize_interval_days"]},
    }
    if p.get("rotate_interval_days"):
        s["rotate"] = {"interval_days": p["rotate_interval_days"]}
    return s


# light: "low" | "indirect" | "bright" | "full-sun"
# difficulty: "Easy" | "Medium" | "Hard"
CATALOG: list[dict] = [
    {**p, "care_schedule" : _schedule(p)} for p in _raw
]


def search_catalog(q: str | None = None) -> list[dict]:
    if not q:
        return CATALOG
    needle = q.strip().lower()
    return [
        item for item in CATALOG
        if needle in item["common_name"].lower() or needle in item["species"].lower()
    ]


def get_species(species_id: str) -> dict | None:
    return next((item for item in CATALOG if item["id"] == species_id), None)
