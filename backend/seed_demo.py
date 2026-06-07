"""
Seed the Bloomly database with realistic demo data for the showcase video.

Run from the backend/ directory (with MongoDB running):

    python seed_demo.py

This WIPES and repopulates: users, plants, articles, comments, likes,
saved_articles. After seeding, log in to the app with:

    email:    demo@bloomly.app
    password: demo1234

All other seeded accounts share the same password (demo1234).
"""
import asyncio
from datetime import datetime, timedelta

from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext

from app.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

NOW = datetime.utcnow()
PASSWORD_HASH = pwd_context.hash("demo1234")


def days_ago(n: float) -> datetime:
    return NOW - timedelta(days=n)


def hours_ago(n: float) -> datetime:
    return NOW - timedelta(hours=n)


def mins_ago(n: float) -> datetime:
    return NOW - timedelta(minutes=n)


# --- image pools (all verified reachable) -----------------------------------
PLANT_PHOTOS = {
    "monstera": "https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=600&q=80",
    "snake": "https://images.unsplash.com/photo-1593691509543-c55fb32d8de5?w=600&q=80",
    "pothos": "https://images.unsplash.com/photo-1545241047-6083a3684587?w=600&q=80",
    "fiddle": "https://images.unsplash.com/photo-1572688484438-313a6e50c333?w=600&q=80",
    "peace_lily": "https://images.unsplash.com/photo-1602923668104-8f9e03e77e62?w=600&q=80",
    "zz": "https://images.unsplash.com/photo-1632207691143-643e2a9a9361?w=600&q=80",
    "generic1": "https://images.unsplash.com/photo-1463320726281-696a485928c7?w=600&q=80",
    "succulent": "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=600&q=80",
}
COVERS = {
    "garden": "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=900&q=80",
    "plants": "https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=900&q=80",
    "propagation": "https://images.unsplash.com/photo-1459156212016-c812468e2115?w=900&q=80",
    "succulent": "https://images.unsplash.com/photo-1591958911259-bee2173bdccc?w=900&q=80",
}


def avatar(n: int) -> str:
    return f"https://i.pravatar.cc/200?img={n}"


# --- users ------------------------------------------------------------------
# The first user is the demo login. avatar=None demonstrates the initials
# fallback in comments/feed for a couple of users.
USERS = [
    {"name": "Aria Meadows", "handle": "aria", "email": "demo@bloomly.app",
     "avatar": avatar(5), "location": "Eindhoven, NL", "climate_zone": "8b"},
    {"name": "Liam Fern", "handle": "liamgrows", "email": "liam@bloomly.app",
     "avatar": avatar(12), "location": "Amsterdam, NL", "climate_zone": "8b"},
    {"name": "Sofia Bloom", "handle": "sofiaplants", "email": "sofia@bloomly.app",
     "avatar": None, "location": "Lisbon, PT", "climate_zone": "10a"},
    {"name": "Noah Vine", "handle": "noahleaf", "email": "noah@bloomly.app",
     "avatar": avatar(33), "location": "Berlin, DE", "climate_zone": "7b"},
    {"name": "Mia Root", "handle": "miaroots", "email": "mia@bloomly.app",
     "avatar": None, "location": "Dublin, IE", "climate_zone": "9a"},
    {"name": "Ethan Moss", "handle": "ethanmoss", "email": "ethan@bloomly.app",
     "avatar": avatar(52), "location": "Manchester, UK", "climate_zone": "9a"},
    {"name": "Olivia Petal", "handle": "livpetals", "email": "olivia@bloomly.app",
     "avatar": None, "location": "Copenhagen, DK", "climate_zone": "7a"},
    {"name": "Kai Sprout", "handle": "kaisprout", "email": "kai@bloomly.app",
     "avatar": avatar(60), "location": "Brussels, BE", "climate_zone": "8a"},
]


def interval(days: int, last_done: datetime | None):
    return {"interval_days": days, "last_done_at": last_done}


# Plants belong to the demo user (aria). States are chosen so the home screen
# reads "6 plants · 3 need attention" (2 overdue + 1 due today).
def build_plants(owner_id: str) -> list[dict]:
    return [
        {
            "owner_id": owner_id,
            "species": "Monstera deliciosa",
            "common_name": "Monstera",
            "nickname": "Monty",
            "location": "Living room",
            "photo_url": PLANT_PHOTOS["monstera"],
            "age_or_acquired_at": "2 years",
            "care_schedule": {
                "water": interval(7, days_ago(9)),       # overdue ~2d  -> bad
                "fertilize": interval(30, days_ago(20)),
                "rotate": interval(14, days_ago(5)),
            },
            "health_log": [
                {"timestamp": days_ago(40), "source": "scan", "diagnosis": "Healthy",
                 "photo_url": PLANT_PHOTOS["monstera"], "notes": "Thriving after repotting."},
                {"timestamp": days_ago(5), "source": "manual", "diagnosis": None,
                 "photo_url": None, "notes": "New fenestrated leaf unfurling 🎉"},
            ],
            "notes": "Loves the bright east window. Rotate weekly for even growth.",
            "created_at": days_ago(60),
        },
        {
            "owner_id": owner_id,
            "species": "Dracaena trifasciata",
            "common_name": "Snake plant",
            "nickname": "Sansa",
            "location": "Bedroom",
            "photo_url": PLANT_PHOTOS["snake"],
            "age_or_acquired_at": "1 year",
            "care_schedule": {
                "water": interval(14, days_ago(10)),     # in ~4d -> happy
                "fertilize": interval(60, days_ago(30)),
            },
            "health_log": [],
            "notes": "Nearly indestructible. Water sparingly.",
            "created_at": days_ago(45),
        },
        {
            "owner_id": owner_id,
            "species": "Ficus lyrata",
            "common_name": "Fiddle leaf fig",
            "nickname": "Frank",
            "location": "Office nook",
            "photo_url": PLANT_PHOTOS["fiddle"],
            "age_or_acquired_at": "8 months",
            "care_schedule": {
                "water": interval(7, days_ago(6.5)),     # due in ~0.5d -> warn (today)
                "fertilize": interval(30, days_ago(10)),
                "prune": interval(90, days_ago(40)),
            },
            "health_log": [
                {"timestamp": days_ago(15), "source": "scan", "diagnosis": "Overwatering",
                 "photo_url": PLANT_PHOTOS["fiddle"],
                 "notes": "Lower leaves yellowing — let the soil dry out more."},
            ],
            "notes": "Dramatic but worth it. Hates being moved.",
            "created_at": days_ago(30),
        },
        {
            "owner_id": owner_id,
            "species": "Epipremnum aureum",
            "common_name": "Golden pothos",
            "nickname": "Goldie",
            "location": "Kitchen shelf",
            "photo_url": PLANT_PHOTOS["pothos"],
            "age_or_acquired_at": "3 years",
            "care_schedule": {
                "water": interval(7, days_ago(2)),       # happy
                "fertilize": interval(30, days_ago(6)),
            },
            "health_log": [],
            "notes": "Trailing beautifully along the cabinets.",
            "created_at": days_ago(70),
        },
        {
            "owner_id": owner_id,
            "species": "Spathiphyllum wallisii",
            "common_name": "Peace lily",
            "nickname": "Lily",
            "location": "Bathroom",
            "photo_url": PLANT_PHOTOS["peace_lily"],
            "age_or_acquired_at": "6 months",
            "care_schedule": {
                "water": interval(5, days_ago(6)),       # overdue 1d -> bad
                "fertilize": interval(30, days_ago(12)),
            },
            "health_log": [
                {"timestamp": days_ago(3), "source": "manual", "diagnosis": None,
                 "photo_url": None, "notes": "Drooping a little — thirsty!"},
            ],
            "notes": "Tells me exactly when it needs water by drooping.",
            "created_at": days_ago(20),
        },
        {
            "owner_id": owner_id,
            "species": "Zamioculcas zamiifolia",
            "common_name": "ZZ plant",
            "nickname": "Zizi",
            "location": "Hallway",
            "photo_url": PLANT_PHOTOS["zz"],
            "age_or_acquired_at": "1.5 years",
            "care_schedule": {
                "water": interval(21, days_ago(4)),      # happy
                "fertilize": interval(45, days_ago(10)),
            },
            "health_log": [],
            "notes": "Perfect for the low-light hallway.",
            "created_at": days_ago(50),
        },
    ]


# Articles: (author_handle, title, body, cover, tags, created_at)
ARTICLES = [
    ("liamgrows", "How I revived my dying fiddle leaf fig",
     "Three months ago my fiddle leaf fig was dropping a leaf a week and I was "
     "ready to give up.\n\nThe culprit turned out to be a combination of "
     "overwatering and a cold draft from a nearby window. Here's what fixed it:\n\n"
     "1. I moved it away from the window and into consistent bright, indirect light.\n"
     "2. I switched to bottom watering and only when the top 5cm were dry.\n"
     "3. A monthly diluted feed during spring.\n\n"
     "Six weeks later it pushed out three new leaves. Patience is everything with these.",
     COVERS["garden"], ["how-to", "ficus"], days_ago(2)),

    ("sofiaplants", "Why won't my monstera leaves split?",
     "My monstera has put out four new leaves this year and none of them have "
     "fenestrated. The plant looks healthy otherwise.\n\n"
     "It's in medium light about 2m from a south window. Should I move it closer? "
     "Is it just too young? Would love to hear what worked for you all.",
     None, ["question", "monstera"], days_ago(4)),

    ("noahleaf", "5 (nearly) unkillable plants for beginners",
     "Just starting out and terrified of killing everything? Start here:\n\n"
     "• ZZ plant — thrives on neglect and low light.\n"
     "• Snake plant — water once a fortnight and forget about it.\n"
     "• Pothos — tells you when it's thirsty by drooping.\n"
     "• Spider plant — bounces back from almost anything.\n"
     "• Cast iron plant — the name says it all.\n\n"
     "Master these and your confidence (and shelf) will grow fast.",
     COVERS["plants"], ["how-to", "beginner"], days_ago(6)),

    ("aria", "My tiny propagation station 🌱",
     "I finally set up a little propagation station on the kitchen windowsill and "
     "it's become my favourite corner of the flat.\n\n"
     "A few test-tube vases, cuttings from my pothos and monstera, and fresh water "
     "every few days. Watching the roots grow is weirdly addictive.\n\n"
     "Next up: potting the first batch that's rooted. Any tips for the transition "
     "from water to soil?",
     COVERS["propagation"], ["how-to", "propagation"], days_ago(3)),

    ("miaroots", "Help! White fuzzy spots on my succulent",
     "Noticed little cotton-like white spots tucked into the leaves of my echeveria "
     "this morning. They wipe off but come back.\n\n"
     "I'm guessing mealybugs? What's the gentlest way to deal with them without "
     "nuking the plant? It's on a shelf with five others I'd hate to infect.",
     COVERS["succulent"], ["question", "pests"], days_ago(1)),

    ("ethanmoss", "Bottom watering changed my plant game",
     "If you struggle with consistent watering, try bottom watering.\n\n"
     "Set the pot in a tray of water for 15–20 minutes and let the soil wick up "
     "what it needs. No more soggy tops and dry centres, and roots grow downward "
     "chasing the moisture.\n\n"
     "My ferns and calatheas have never looked better.",
     None, ["how-to", "watering"], hours_ago(20)),

    ("aria", "Show me your plant shelves 🌿",
     "It's grey outside and I want to see some greenery. Drop a photo of your "
     "favourite plant shelf or corner below — I'll start!\n\n"
     "Mine is a three-tier cart by the balcony door that's slowly taking over the "
     "living room. No regrets.",
     None, ["community"], hours_ago(8)),
]

# Comments: (article_index, author_handle, body, created_at)
COMMENTS = [
    (0, "aria", "This is so encouraging — mine is dropping leaves right now. Trying the bottom watering tip!", hours_ago(30)),
    (0, "noahleaf", "Cold drafts are such an underrated killer. Glad you saved it 🙌", hours_ago(20)),
    (0, "kaisprout", "How diluted is your monthly feed? Half strength?", hours_ago(6)),
    (0, "liamgrows", "@kaisprout yep, half strength every 4 weeks in spring/summer only.", mins_ago(40)),

    (1, "ethanmoss", "Mine didn't split until it got really bright light. Move it closer and be patient.", days_ago(3)),
    (1, "noahleaf", "Also age + a moss pole helped mine fenestrate a lot faster.", days_ago(2)),
    (1, "aria", "Same experience here — light was the missing piece for me.", hours_ago(18)),

    (2, "miaroots", "Saving this, thank you! Starting with a ZZ this weekend.", days_ago(5)),
    (2, "sofiaplants", "Spider plants are the best for beginners, totally agree.", days_ago(4)),

    (3, "liamgrows", "Love this! For water-to-soil, keep it extra moist the first 2 weeks so the roots adjust.", hours_ago(40)),
    (3, "sofiaplants", "Your setup is adorable 😍 what vases are those?", hours_ago(20)),
    (3, "ethanmoss", "Rooting hormone isn't needed for pothos — they root in days. Monstera takes longer.", hours_ago(10)),
    (3, "kaisprout", "Following for the soil tips!", mins_ago(25)),

    (4, "noahleaf", "Definitely mealybugs. Dab them with a cotton bud dipped in 70% isopropyl alcohol.", hours_ago(18)),
    (4, "aria", "Isolate it from the others ASAP — they spread fast!", hours_ago(9)),
    (4, "ethanmoss", "Neem oil spray weekly for a month sorted mine out.", hours_ago(4)),

    (5, "aria", "Just tried this with my calathea, instant difference. Thanks for sharing!", hours_ago(12)),
    (5, "livpetals", "Does this work for plants in terracotta too?", hours_ago(3)),

    (6, "noahleaf", "Here's mine — south-facing chaos 🌿", hours_ago(6)),
    (6, "miaroots", "Three-tier cart gang 🙌", hours_ago(4)),
    (6, "liamgrows", "Goals. Mine is one sad windowsill by comparison 😅", mins_ago(50)),
]

# Likes: (article_index, [handles who liked])
LIKES = [
    (0, ["aria", "noahleaf", "kaisprout", "miaroots", "ethanmoss", "sofiaplants"]),
    (1, ["noahleaf", "ethanmoss"]),
    (2, ["aria", "miaroots", "sofiaplants", "livpetals", "kaisprout"]),
    (3, ["liamgrows", "sofiaplants", "ethanmoss", "kaisprout", "noahleaf", "miaroots", "livpetals"]),
    (4, ["noahleaf", "aria", "ethanmoss"]),
    (5, ["aria", "livpetals", "noahleaf", "kaisprout"]),
    (6, ["noahleaf", "miaroots", "liamgrows", "sofiaplants"]),
]

# Saved articles by the demo user (aria).
SAVED_BY_ARIA = [0, 2]


async def main():
    client = AsyncIOMotorClient(settings.mongo_url)
    db = client[settings.database_name]

    print(f"Seeding '{settings.database_name}' at {settings.mongo_url} …")

    # Wipe
    for coll in ["users", "plants", "articles", "comments", "likes", "saved_articles"]:
        await db[coll].delete_many({})

    # Users
    handle_to_id: dict[str, str] = {}
    for u in USERS:
        doc = {**u, "password_hash": PASSWORD_HASH, "created_at": days_ago(120)}
        res = await db.users.insert_one(doc)
        handle_to_id[u["handle"]] = str(res.inserted_id)
    print(f"  users: {len(USERS)}")

    aria_id = handle_to_id["aria"]

    # Plants (demo user)
    plants = build_plants(aria_id)
    await db.plants.insert_many(plants)
    print(f"  plants: {len(plants)} (owner @aria)")

    # Articles
    article_ids: list[str] = []
    for author_handle, title, body, cover, tags, created_at in ARTICLES:
        doc = {
            "author_id": handle_to_id[author_handle],
            "title": title,
            "body": body,
            "cover_photo": cover,
            "tags": tags,
            "linked_plant_ids": [],
            "created_at": created_at,
        }
        res = await db.articles.insert_one(doc)
        article_ids.append(str(res.inserted_id))
    print(f"  articles: {len(article_ids)}")

    # Comments
    comment_docs = []
    for idx, handle, body, created_at in COMMENTS:
        comment_docs.append({
            "article_id": article_ids[idx],
            "author_id": handle_to_id[handle],
            "body": body,
            "created_at": created_at,
        })
    if comment_docs:
        await db.comments.insert_many(comment_docs)
    print(f"  comments: {len(comment_docs)}")

    # Likes
    like_docs = []
    for idx, handles in LIKES:
        for h in handles:
            like_docs.append({"article_id": article_ids[idx], "user_id": handle_to_id[h]})
    if like_docs:
        await db.likes.insert_many(like_docs)
    print(f"  likes: {len(like_docs)}")

    # Saved
    saved_docs = [
        {"article_id": article_ids[idx], "user_id": aria_id, "saved_at": days_ago(idx + 1)}
        for idx in SAVED_BY_ARIA
    ]
    if saved_docs:
        await db.saved_articles.insert_many(saved_docs)
    print(f"  saved_articles: {len(saved_docs)}")

    client.close()
    print("\nDone. Log in with  demo@bloomly.app  /  demo1234")


if __name__ == "__main__":
    asyncio.run(main())
