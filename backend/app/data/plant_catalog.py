"""
A small built-in catalog of common houseplants with default care schedules.

Used by the "Search by name" and "Find your plant" (quiz) add-plant flows so
users can add a plant in one tap without the scan feature. Static data — always
available and never wiped by the demo seed.
"""

_PHOTO = "https://images.unsplash.com/photo-{pid}?w=600&q=80"


def _photo(pid: str) -> str:
    return _PHOTO.format(pid=pid)


def _schedule(water: int, fertilize: int, rotate: int | None = None, prune: int | None = None) -> dict:
    sched: dict = {
        "water": {"interval_days": water},
        "fertilize": {"interval_days": fertilize},
    }
    if rotate is not None:
        sched["rotate"] = {"interval_days": rotate}
    if prune is not None:
        sched["prune"] = {"interval_days": prune}
    return sched


# light: "low" | "indirect" | "bright" | "full-sun"
# difficulty: "Easy" | "Medium" | "Hard"
CATALOG: list[dict] = [
    {
        "id": "pothos", "common_name": "Golden pothos", "species": "Epipremnum aureum",
        "emoji": "🌿", "photo_url": _photo("1545241047-6083a3684587"),
        "description": "Trailing vine that thrives almost anywhere. Tells you when it's thirsty by drooping.",
        "light": "low", "humidity": False, "pet_safe": False, "difficulty": "Easy",
        "care_schedule": _schedule(7, 30),
    },
    {
        "id": "snake-plant", "common_name": "Snake plant", "species": "Dracaena trifasciata",
        "emoji": "🪴", "photo_url": _photo("1593691509543-c55fb32d8de5"),
        "description": "Nearly indestructible, architectural, and air-purifying. Water sparingly.",
        "light": "low", "humidity": False, "pet_safe": False, "difficulty": "Easy",
        "care_schedule": _schedule(14, 60),
    },
    {
        "id": "zz-plant", "common_name": "ZZ plant", "species": "Zamioculcas zamiifolia",
        "emoji": "🌿", "photo_url": _photo("1632207691143-643e2a9a9361"),
        "description": "Glossy leaves and a cast-iron tolerance for neglect and low light.",
        "light": "low", "humidity": False, "pet_safe": False, "difficulty": "Easy",
        "care_schedule": _schedule(21, 45),
    },
    {
        "id": "spider-plant", "common_name": "Spider plant", "species": "Chlorophytum comosum",
        "emoji": "🕸", "photo_url": _photo("1509423350716-97f9360b4e09"),
        "description": "Fast-growing, pet-safe, and produces adorable baby plantlets.",
        "light": "indirect", "humidity": False, "pet_safe": True, "difficulty": "Easy",
        "care_schedule": _schedule(7, 30),
    },
    {
        "id": "monstera", "common_name": "Monstera", "species": "Monstera deliciosa",
        "emoji": "🌱", "photo_url": _photo("1614594975525-e45190c55d0b"),
        "description": "The iconic Swiss cheese plant. Big, fenestrated leaves with a little care.",
        "light": "indirect", "humidity": False, "pet_safe": False, "difficulty": "Medium",
        "care_schedule": _schedule(7, 30, rotate=14),
    },
    {
        "id": "peace-lily", "common_name": "Peace lily", "species": "Spathiphyllum wallisii",
        "emoji": "🌷", "photo_url": _photo("1602923668104-8f9e03e77e62"),
        "description": "Elegant white blooms and lush leaves; happy in lower light and humidity.",
        "light": "indirect", "humidity": True, "pet_safe": False, "difficulty": "Medium",
        "care_schedule": _schedule(5, 30),
    },
    {
        "id": "calathea", "common_name": "Calathea", "species": "Calathea orbifolia",
        "emoji": "🌿", "photo_url": _photo("1604762524889-3e2fcc145683"),
        "description": "Stunning patterned leaves that fold up at night. Loves humidity, pet-safe.",
        "light": "indirect", "humidity": True, "pet_safe": True, "difficulty": "Hard",
        "care_schedule": _schedule(5, 30),
    },
    {
        "id": "fiddle-leaf-fig", "common_name": "Fiddle leaf fig", "species": "Ficus lyrata",
        "emoji": "🌳", "photo_url": _photo("1572688484438-313a6e50c333"),
        "description": "Statement plant with violin-shaped leaves. Dramatic but rewarding.",
        "light": "bright", "humidity": False, "pet_safe": False, "difficulty": "Hard",
        "care_schedule": _schedule(7, 30, prune=90),
    },
    {
        "id": "rubber-plant", "common_name": "Rubber plant", "species": "Ficus elastica",
        "emoji": "🌿", "photo_url": _photo("1611211232932-da3113c5b960"),
        "description": "Glossy burgundy-green leaves; grows into a striking indoor tree.",
        "light": "indirect", "humidity": False, "pet_safe": False, "difficulty": "Medium",
        "care_schedule": _schedule(9, 30),
    },
    {
        "id": "philodendron", "common_name": "Heartleaf philodendron", "species": "Philodendron hederaceum",
        "emoji": "💚", "photo_url": _photo("1463320726281-696a485928c7"),
        "description": "Easy trailing heart-shaped leaves; forgiving of lower light.",
        "light": "low", "humidity": False, "pet_safe": False, "difficulty": "Easy",
        "care_schedule": _schedule(7, 30),
    },
    {
        "id": "pilea", "common_name": "Chinese money plant", "species": "Pilea peperomioides",
        "emoji": "🪙", "photo_url": _photo("1487070183336-b863922373d4"),
        "description": "Quirky coin-shaped leaves; pet-safe and loves bright indirect light.",
        "light": "indirect", "humidity": False, "pet_safe": True, "difficulty": "Easy",
        "care_schedule": _schedule(7, 30, rotate=7),
    },
    {
        "id": "boston-fern", "common_name": "Boston fern", "species": "Nephrolepis exaltata",
        "emoji": "🌿", "photo_url": _photo("1542728928-1413d1894ed1"),
        "description": "Lush, feathery fronds. Pet-safe and perfect for humid bathrooms.",
        "light": "indirect", "humidity": True, "pet_safe": True, "difficulty": "Medium",
        "care_schedule": _schedule(4, 30),
    },
    {
        "id": "aloe-vera", "common_name": "Aloe vera", "species": "Aloe barbadensis",
        "emoji": "🌵", "photo_url": _photo("1525498128493-380d1990a112"),
        "description": "Hardy succulent with soothing gel. Loves sun, hates wet feet.",
        "light": "full-sun", "humidity": False, "pet_safe": False, "difficulty": "Easy",
        "care_schedule": _schedule(14, 60),
    },
    {
        "id": "echeveria", "common_name": "Echeveria succulent", "species": "Echeveria elegans",
        "emoji": "🌵", "photo_url": _photo("1485955900006-10f4d324d411"),
        "description": "Rosette-forming succulent. Bright sun and infrequent watering.",
        "light": "full-sun", "humidity": False, "pet_safe": True, "difficulty": "Easy",
        "care_schedule": _schedule(14, 60),
    },
    {
        "id": "jade-plant", "common_name": "Jade plant", "species": "Crassula ovata",
        "emoji": "🌳", "photo_url": _photo("1459156212016-c812468e2115"),
        "description": "Tree-like succulent said to bring luck. Thrives on bright light and neglect.",
        "light": "full-sun", "humidity": False, "pet_safe": False, "difficulty": "Easy",
        "care_schedule": _schedule(14, 60),
    },
    {
        "id": "areca-palm", "common_name": "Areca palm", "species": "Dypsis lutescens",
        "emoji": "🌴", "photo_url": _photo("1466692476868-aef1dfb1e735"),
        "description": "Feathery tropical palm that brings a resort feel indoors. Pet-safe.",
        "light": "bright", "humidity": True, "pet_safe": True, "difficulty": "Medium",
        "care_schedule": _schedule(6, 30),
    },
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
