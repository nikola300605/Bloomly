import json
import re
import time
import urllib.request
import urllib.parse

with open("plants_raw.json", encoding="utf-8") as f:
    plants = json.load(f)

HEADERS = {"User-Agent": "BloomlyApp/1.0 (plant catalog enrichment; contact@bloomly.app)"}

OVERRIDES = {
  "ZZ Plant": "Zamioculcas",
  "Aloe Vera": "Aloe vera",
  "Dragon Tree": "Dracaena marginata",
  "Areca Palm": "Dypsis lutescens",
  "Pinstripe Calathea": "Calathea ornata",
  "African Violet": "African violet",
  "Christmas Cactus": "Schlumbergera × buckleyi",
  "Golden Barrel Cactus": "Echinocactus grusonii",
  "Totem Pole Cactus": "Lophocereus schottii",
  "Cymbidium Orchid": "Cymbidium",
  "Umbrella Plant": "Schefflera arboricola",
  "Alocasia Polly": "Alocasia × amazonica",
  "Kangaroo Paw Fern": "Microsorum diversifolium",
  "String of Dolphins": "Curio × peregrinus",
  "Tradescantia Nanouk": "Tradescantia 'Nanouk'",
  "Meyer Lemon": "Meyer lemon",
  "Avocado Plant": "Avocado",
  "Pineapple Plant": "Pineapple",
  "Mint": "Mentha",
  "Venus Flytrap": "Dionaea muscipula",
  "Stromanthe Triostar": "Stromanthe sanguinea",
  "Tropical Hibiscus": "Hibiscus rosa-sinensis",
  "Philodendron Xanadu": "Thaumatophyllum xanadu",
  "Mosaic Plant": "Fittonia albivenis",
  "Baby Tears": "Soleirolia soleirolii"
}

def _thumbnail(title: str) -> str | None:
    """Return Wikipedia thumbnail URL for a page title, or None."""
    url = (
        "https://en.wikipedia.org/w/api.php?action=query"
        f"&titles={urllib.parse.quote(title.replace(' ', '_'))}"
        "&prop=pageimages&format=json&pithumbsize=600"
    )
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=8) as res:
            data = json.loads(res.read())
        page = next(iter(data["query"]["pages"].values()))
        return page.get("thumbnail", {}).get("source")
    except Exception:
        return None


def _base_species(species: str) -> str:
    """Strip cultivar suffixes and author citations so Wikipedia can find the page.

    'Epipremnum aureum 'Neon'' -> 'Epipremnum aureum'
    'Aloe barbadensis miller'  -> 'Aloe barbadensis'
    'Alocasia x amazonica'     -> 'Alocasia amazonica'
    """
    s = re.sub(r"\s*'[^']*'", "", species)   # remove 'CultivarName'
    s = re.sub(r"\s+x\s+", " ", s)            # Genus x species -> Genus species
    parts = s.split()
    # Strip trailing author citation (third+ word that starts lowercase)
    if len(parts) >= 3 and parts[2][0].islower():
        s = " ".join(parts[:2])
    return s.strip()


errors = 0
for plant in plants:
    # 0. Check manual override first
    override = OVERRIDES.get(plant["common_name"])
    if override:
        photo = _thumbnail(override)
    else:
        photo = _thumbnail(plant["species"])
        if not photo:
            base = _base_species(plant["species"])
            if base != plant["species"]:
                photo = _thumbnail(base)
        if not photo:
            photo = _thumbnail(plant["common_name"])

    plant["photo_url"] = photo

with open("plants_enriched.json", "w", encoding="utf-8") as f:
    json.dump(plants, f, indent=2, ensure_ascii=False)

print(f"Done. {sum(1 for p in plants if p['photo_url'])} / {len(plants)} photos found.")