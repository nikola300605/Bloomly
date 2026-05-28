from datetime import datetime, timedelta
from typing import Optional, List

from app.models.care_task import CareTaskOut

_TASK_ICONS = {
    "water": "💧",
    "fertilize": "🧂",
    "rotate": "☀",
    "prune": "✂",
}


def _next_due(last_done_at: Optional[datetime], interval_days: int) -> datetime:
    if last_done_at is None:
        return datetime.utcnow()
    return last_done_at + timedelta(days=interval_days)


def compute_care_badge(care_schedule: dict) -> Optional[dict]:
    """Return the single worst care badge across all tasks, or None if no tasks."""
    if not care_schedule:
        return None

    now = datetime.utcnow()
    priority = {"bad": 3, "warn": 2, "info": 1, "ok": 0}
    worst: dict = {"kind": "ok", "label": "✓ happy"}

    for task_kind, schedule in care_schedule.items():
        if not schedule:
            continue
        interval = schedule.get("interval_days", 7)
        last_done = schedule.get("last_done_at")
        if isinstance(last_done, str):
            last_done = datetime.fromisoformat(last_done.replace("Z", "+00:00")).replace(tzinfo=None)

        next_due = _next_due(last_done, interval)
        delta_days = (next_due - now).total_seconds() / 86400
        icon = _TASK_ICONS.get(task_kind, "•")

        if delta_days < 0:
            overdue = max(1, int(abs(delta_days)))
            kind = "bad"
            label = f"{icon} overdue {overdue}d"
        elif delta_days < 1:
            kind = "warn"
            label = f"{icon} {task_kind} today"
        elif delta_days <= 2:
            kind = "info"
            label = f"{icon} in {int(delta_days)}d"
        else:
            continue  # upcoming — doesn't need a badge

        if priority.get(kind, 0) > priority.get(worst["kind"], 0):
            worst = {"kind": kind, "label": label}

    return worst


def get_care_tasks(plant_doc: dict) -> List[CareTaskOut]:
    """Derive a flat list of CareTaskOut from a raw plant document."""
    now = datetime.utcnow()
    tasks: List[CareTaskOut] = []
    care_schedule = plant_doc.get("care_schedule") or {}
    plant_id = str(plant_doc["_id"])
    plant_name = plant_doc.get("nickname") or plant_doc.get("common_name", "Plant")
    plant_photo_url = plant_doc.get("photo_url")

    for task_kind, schedule in care_schedule.items():
        if not schedule:
            continue
        interval = schedule.get("interval_days", 7)
        last_done = schedule.get("last_done_at")
        if isinstance(last_done, str):
            last_done = datetime.fromisoformat(last_done.replace("Z", "+00:00")).replace(tzinfo=None)

        next_due = _next_due(last_done, interval)
        delta_days = (next_due - now).total_seconds() / 86400
        overdue_days = max(0, int(abs(min(0, delta_days))))
        icon = _TASK_ICONS.get(task_kind, "•")

        if delta_days < 0:
            badge_kind = "bad"
            badge_label = f"{icon} overdue {overdue_days}d"
        elif delta_days < 1:
            badge_kind = "warn"
            badge_label = f"{icon} {task_kind} today"
        else:
            badge_kind = "info"
            badge_label = f"{icon} in {int(delta_days)}d"

        tasks.append(CareTaskOut(
            id=f"{plant_id}-{task_kind}",
            plant_id=plant_id,
            plant_name=plant_name,
            plant_photo_url=plant_photo_url,
            kind=task_kind,
            due_at=next_due,
            overdue_days=overdue_days,
            badge_kind=badge_kind,
            badge_label=badge_label,
        ))

    return tasks
