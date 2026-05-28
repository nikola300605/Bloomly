---
name: project-bloomly
description: Bloomly MVP — gardening helper app. Flutter + FastAPI + MongoDB scaffold created May 2026.
metadata:
  type: project
---

Bloomly is a mobile gardening helper app scaffolded in May 2026 from a design handoff located at `design_handoff_bloomly_mvp/`.

**Why:** The user wants to build an MVP of a plant-care app with AI-powered plant identification and diagnosis.

**Stack decided:**
- Flutter (mobile) — in `bloomly/mobile/`
- FastAPI backend (Python 3.12) — in `bloomly/backend/`
- MongoDB via Motor (async driver) — spun up via docker-compose

**How to apply:** When working on Bloomly, the backend is FastAPI + Motor + MongoDB, and the mobile app is Flutter with Riverpod (state management) and go_router (navigation).

---

## Key architecture decisions

- **Flutter state management:** flutter_riverpod (FutureProvider, StateNotifierProvider)
- **Navigation:** go_router with ShellRoute for the persistent bottom nav (Plants / Community / Profile)
- **Auth:** JWT tokens stored in flutter_secure_storage; Google + Apple + Email supported (Google/Apple stubs pending)
- **Scan FAB:** center-docked FloatingActionButton in the BottomAppBar, pushes `/scan`
- **Backend auth:** `app/dependencies.py` → `get_current_user_id()` JWT dependency; **all auth endpoints are stubbed** — email signup/login implemented, Google/Apple return 501
- **AI scan:** `app/services/ai_scan.py` returns stubs; real provider is wired by setting `AI_SERVICE_URL` + `AI_API_KEY` in `.env`
- **Care badge logic:** lives in `app/services/care_scheduler.py`; badges: ok/info/warn/bad based on days until due

## File structure
```
bloomly/
  docker-compose.yml
  backend/
    .env, .env.example, Dockerfile, requirements.txt
    app/
      main.py, config.py, database.py, dependencies.py
      models/  (user, plant, article, scan, care_task)
      routers/ (auth, plants, scan, articles, users)
      services/(ai_scan, care_scheduler)
  mobile/
    pubspec.yaml
    lib/
      main.dart, app.dart
      core/  (theme, constants, router)
      data/  (models, api, repositories)
      shared/widgets/ (CareBadge, BloomlyBottomNav, PlantThumbnail, LoadingSkeleton)
      features/
        auth, home, plant_detail, add_plant
        scan (camera → symptoms → results)
        recommendations (quiz → results)
        notifications (care_schedule)
        community (feed, article, write_article)
        profile
```

## Recommended next steps
1. Add fonts (SpaceGrotesk) to `mobile/assets/fonts/` — pubspec.yaml already references them
2. Wire Google/Apple auth (backend `routers/auth.py`)
3. Connect real AI service in `backend/app/services/ai_scan.py`
4. Add push notifications for care reminders
5. Add onboarding flow (3-question setup after first login)
6. Wire plant catalog/species search
