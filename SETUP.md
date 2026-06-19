# Running Bloomly locally

## Prerequisites

- Flutter SDK in PATH
- Docker Desktop (backend + MongoDB run in containers)
- Android emulator, or a physical Android phone with USB debugging enabled

## 1. Start the backend

```
cd bloomly
docker compose up -d
```

This starts MongoDB and the FastAPI backend on `http://localhost:8000`
(check: open http://localhost:8000/docs).

- After changing `requirements.txt`, rebuild the image: `docker compose up -d --build`
- Code changes under `backend/` hot-reload automatically (volume mount + `--reload`).
- Seed demo data: `docker exec bloomly-backend-1 python seed_demo.py`
  (demo login: `demo@bloomly.app` / `demo1234`)

## 2. Run the app — emulator or USB phone, same command

```
cd mobile
flutter run
```

That's it. Two mechanisms make this work on any local target with no flags:

1. **Auto tunnel** — the `adbReverse` Gradle task (in `android/app/build.gradle.kts`)
   runs `adb reverse tcp:8000 tcp:8000` for every attached device on each debug
   build, so `localhost:8000` on the device reaches this machine's backend.
   This works over USB; it does NOT require the phone and PC to share a network.
2. **Runtime probing** — debug builds probe `localhost:8000` then `10.0.2.2:8000`
   against `GET /health` and use whichever answers (see
   `mobile/lib/data/api/api_client.dart`). After a connection failure the app
   re-probes on the next request, so a restored tunnel is picked up without
   restarting the app.

To target a different backend (LAN, staging, production), set it explicitly —
this disables probing and is required for release builds:

```
flutter run --dart-define=API_BASE_URL=http://<host>:8000
```

## Troubleshooting

**App times out on a physical phone**

The `adb reverse` tunnel dies whenever the USB cable is unplugged or adb
restarts, and launching the installed app from the phone's launcher doesn't
recreate it. Fix from `mobile/`:

```
.\run-phone.ps1        # restores the tunnel on all devices, then flutter run
```

or just restore the tunnel for an already-running app (takes effect on the
app's next request — no rebuild or restart needed):

```
adb reverse tcp:8000 tcp:8000
```

**Phone unplugged / wireless use**: the tunnel only exists over USB (or
`adb connect` over Wi-Fi). Campus/office networks usually block direct
phone→PC traffic, so untethered use needs a network where both ends can talk
(home Wi-Fi or phone hotspot) plus `--dart-define=API_BASE_URL` with the PC's
LAN IP, or a deployed backend.

**Backend not responding**: `docker compose ps` (both services up?), then
`docker logs bloomly-backend-1 --tail 20`. A crash-loop right after editing
`requirements.txt` means the image needs a rebuild: `docker compose up -d --build`.
