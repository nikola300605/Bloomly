class CareInterval {
  final int intervalDays;
  final DateTime? lastDoneAt;

  const CareInterval({required this.intervalDays, this.lastDoneAt});

  factory CareInterval.fromJson(Map<String, dynamic> j) => CareInterval(
        intervalDays: j['interval_days'] as int,
        lastDoneAt: j['last_done_at'] != null ? DateTime.parse(j['last_done_at'] as String) : null,
      );

  DateTime get nextDue {
    final base = lastDoneAt ?? DateTime.now();
    return base.add(Duration(days: intervalDays));
  }
}

class CareSchedule {
  final CareInterval water;
  final CareInterval fertilize;
  final CareInterval? rotate;
  final CareInterval? prune;

  const CareSchedule({required this.water, required this.fertilize, this.rotate, this.prune});

  factory CareSchedule.fromJson(Map<String, dynamic> j) => CareSchedule(
        water: CareInterval.fromJson(j['water'] as Map<String, dynamic>),
        fertilize: CareInterval.fromJson(j['fertilize'] as Map<String, dynamic>),
        rotate: j['rotate'] != null ? CareInterval.fromJson(j['rotate'] as Map<String, dynamic>) : null,
        prune: j['prune'] != null ? CareInterval.fromJson(j['prune'] as Map<String, dynamic>) : null,
      );
}

class CareBadge {
  final String kind; // "ok" | "warn" | "bad" | "info"
  final String label;

  const CareBadge({required this.kind, required this.label});

  factory CareBadge.fromJson(Map<String, dynamic> j) =>
      CareBadge(kind: j['kind'] as String, label: j['label'] as String);
}

class HealthLogEntry {
  final DateTime timestamp;
  final String source;
  final String? diagnosis;
  final String? photoUrl;
  final String? notes;

  const HealthLogEntry({
    required this.timestamp,
    required this.source,
    this.diagnosis,
    this.photoUrl,
    this.notes,
  });

  factory HealthLogEntry.fromJson(Map<String, dynamic> j) => HealthLogEntry(
        timestamp: DateTime.parse(j['timestamp'] as String),
        source: j['source'] as String,
        diagnosis: j['diagnosis'] as String?,
        photoUrl: j['photo_url'] as String?,
        notes: j['notes'] as String?,
      );
}

class PlantModel {
  final String id;
  final String ownerId;
  final String species;
  final String commonName;
  final String? nickname;
  final String? location;
  final String? photoUrl;
  final String? ageOrAcquiredAt;
  final CareSchedule careSchedule;
  final List<HealthLogEntry> healthLog;
  final String? notes;
  final DateTime createdAt;
  final CareBadge? nextCareBadge;

  String get displayName => nickname?.isNotEmpty == true ? nickname! : commonName;

  const PlantModel({
    required this.id,
    required this.ownerId,
    required this.species,
    required this.commonName,
    this.nickname,
    this.location,
    this.photoUrl,
    this.ageOrAcquiredAt,
    required this.careSchedule,
    required this.healthLog,
    this.notes,
    required this.createdAt,
    this.nextCareBadge,
  });

  factory PlantModel.fromJson(Map<String, dynamic> j) => PlantModel(
        id: j['id'] as String,
        ownerId: j['owner_id'] as String,
        species: j['species'] as String,
        commonName: j['common_name'] as String,
        nickname: j['nickname'] as String?,
        location: j['location'] as String?,
        photoUrl: j['photo_url'] as String?,
        ageOrAcquiredAt: j['age_or_acquired_at'] as String?,
        careSchedule: CareSchedule.fromJson(j['care_schedule'] as Map<String, dynamic>),
        healthLog: (j['health_log'] as List? ?? [])
            .map((e) => HealthLogEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        nextCareBadge: j['next_care_badge'] != null
            ? CareBadge.fromJson(j['next_care_badge'] as Map<String, dynamic>)
            : null,
      );
}
