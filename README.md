# Bloomly 🌿

A smart gardening helper. Bloomly keeps track of your houseplants, tells you when
to water them, identifies plants from a photo, and gives you a small community to
swap tips with.

This repo is an MVP: a Flutter app backed by a FastAPI + MongoDB service.

---

## What it does

- **Your plant collection** — a home screen listing your plants with at-a-glance
  care badges ("water today", "overdue 2d", "happy").
- **Plant details & care guide** — per-plant watering/fertilizing cadence, a
  health log, and quick "mark done" / "snooze" actions.
- **Add a plant, three ways** — search a built-in catalog of common houseplants,
  take a short quiz for recommendations, or add one manually. (A camera "scan to
  identify" flow also exists but is a stub for now — see notes below.)
- **Care reminders** — local notifications scheduled from each plant's watering
  interval (Android).
- **Community** — an article feed with filters, like/save, full article view, and
  comments you can read and post.
- **Profile** — avatar (or initials), your plant and post counts, and your posts.
- **Accounts** — email sign-up / login with JWT, plus silent token refresh so you
  don't get logged out mid-session.

---

## Tech stack

**Mobile** (`mobile/`)
- Flutter / Dart
- Riverpod (state management), go_router (navigation), Dio (HTTP)
- flutter_local_notifications, image_picker, cached_network_image

**Backend** (`backend/`)
- FastAPI
- MongoDB via Motor (async driver)
- JWT auth (python-jose) with bcrypt password hashing

**Infra**
- Docker Compose for MongoDB + backend

---

## Project structure

```
.
├── backend/
│   ├── app/
│   │   ├── routers/      # auth, plants, scan, articles, users, catalog
│   │   ├── models/       # Pydantic schemas
│   │   ├── services/     # care scheduler, AI scan (stub)
│   │   ├── data/         # built-in plant catalog
│   │   └── main.py
│   ├── seed_demo.py      # populates the DB with demo data
│   ├── requirements.txt
│   └── Dockerfile
├── mobile/
│   └── lib/
│       ├── core/         # theme, router, services, utils
│       ├── data/         # api client, models, repositories
│       ├── features/     # auth, home, plant_detail, add_plant,
│       │                 # community, profile, scan, recommendations
│       └── shared/       # reusable widgets
├── docker-compose.yml
└── SETUP.md              # running on a physical Android device
```

---

## Getting started

### Prerequisites
- Flutter SDK
- Python 3.12+
- MongoDB (locally, or via the included Docker Compose)

### 1. Backend

```bash
cd backend
cp .env.example .env          # then set MONGO_URL=mongodb://localhost:27017 for local dev
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Or run MongoDB + backend together with Docker:

```bash
docker compose up
```

The API is then at `http://localhost:8000` (interactive docs at `/docs`).

### 2. Mobile

```bash
cd mobile
flutter pub get
flutter run
```

The app reads the API base URL from a compile-time constant
(`API_BASE_URL`, defaulting to a LAN IP). To point it at your machine:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-lan-ip>:8000
```

Running on a **physical Android device** (Wi-Fi, firewall, IP) is covered
step-by-step in [SETUP.md](SETUP.md).

### 3. Demo data (optional)

To fill the database with sample plants, users, articles, and comments:

```bash
cd backend
python seed_demo.py
```

Then log in with:

```
email:    demo@bloomly.app
password: demo1234
```

---

## Notes & current limitations

This is an MVP, so a few things are intentionally simplified:

- **Plant identification / diagnosis** returns built-in sample results. Wire a
  real provider by setting `AI_SERVICE_URL` and `AI_API_KEY` in `.env`.
- **Google / Apple sign-in** is scaffolded but not wired up — email auth is the
  working path.
- **Notifications** are Android-only (there's no iOS project in the repo).
- **Cleartext HTTP** is enabled for debug builds only, so the app can talk to a
  local backend; release builds stay HTTPS-only.
- `pubspec.lock` is gitignored, so run `flutter pub get` after cloning.

---

## License

See [LICENSE](LICENSE).
