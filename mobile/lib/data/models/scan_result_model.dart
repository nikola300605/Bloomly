class ScanCandidate {
  final String name;
  final double confidence;
  final String? description;
  final String? photoUrl;

  const ScanCandidate({
    required this.name,
    required this.confidence,
    this.description,
    this.photoUrl,
  });

  factory ScanCandidate.fromJson(Map<String, dynamic> j) => ScanCandidate(
        name: j['name'] as String,
        confidence: (j['confidence'] as num).toDouble(),
        description: j['description'] as String?,
        photoUrl: j['photo_url'] as String?,
      );
}

class ScanActionStep {
  final String icon;
  final String title;
  final String description;

  const ScanActionStep({required this.icon, required this.title, required this.description});

  factory ScanActionStep.fromJson(Map<String, dynamic> j) => ScanActionStep(
        icon: j['icon'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
      );
}

class ScanResultModel {
  final String id;
  final String? plantId;
  final String mode; // "identify" | "diagnose"
  final List<ScanCandidate> topCandidates;
  final String? diagnosis;
  final double? confidence;
  final bool lowConfidence;
  final String? explanation;
  final List<ScanActionStep> actionSteps;
  final String? photoUrl;
  final DateTime createdAt;

  const ScanResultModel({
    required this.id,
    this.plantId,
    required this.mode,
    required this.topCandidates,
    this.diagnosis,
    this.confidence,
    required this.lowConfidence,
    this.explanation,
    required this.actionSteps,
    this.photoUrl,
    required this.createdAt,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> j) => ScanResultModel(
        id: j['id'] as String,
        plantId: j['plant_id'] as String?,
        mode: j['mode'] as String,
        topCandidates: (j['top_candidates'] as List? ?? [])
            .map((e) => ScanCandidate.fromJson(e as Map<String, dynamic>))
            .toList(),
        diagnosis: j['diagnosis'] as String?,
        confidence: j['confidence'] != null ? (j['confidence'] as num).toDouble() : null,
        lowConfidence: j['low_confidence'] as bool? ?? false,
        explanation: j['explanation'] as String?,
        actionSteps: (j['action_steps'] as List? ?? [])
            .map((e) => ScanActionStep.fromJson(e as Map<String, dynamic>))
            .toList(),
        photoUrl: j['photo_url'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
