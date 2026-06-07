/// A species from the built-in plant catalog (used by the search and quiz
/// add-plant flows).
class SpeciesModel {
  final String id;
  final String commonName;
  final String species;
  final String emoji;
  final String? photoUrl;
  final String? description;
  final String light; // "low" | "indirect" | "bright" | "full-sun"
  final bool humidity;
  final bool petSafe;
  final String difficulty; // "Easy" | "Medium" | "Hard"
  final Map<String, dynamic> careSchedule;

  const SpeciesModel({
    required this.id,
    required this.commonName,
    required this.species,
    required this.emoji,
    this.photoUrl,
    this.description,
    required this.light,
    required this.humidity,
    required this.petSafe,
    required this.difficulty,
    required this.careSchedule,
  });

  factory SpeciesModel.fromJson(Map<String, dynamic> j) => SpeciesModel(
        id: j['id'] as String,
        commonName: j['common_name'] as String,
        species: j['species'] as String,
        emoji: j['emoji'] as String? ?? '🌿',
        photoUrl: j['photo_url'] as String?,
        description: j['description'] as String?,
        light: j['light'] as String? ?? 'indirect',
        humidity: j['humidity'] as bool? ?? false,
        petSafe: j['pet_safe'] as bool? ?? false,
        difficulty: j['difficulty'] as String? ?? 'Easy',
        careSchedule: Map<String, dynamic>.from(j['care_schedule'] as Map? ?? const {}),
      );

  /// Payload for `PlantRepository.createPlant`.
  Map<String, dynamic> toCreatePayload({String? nickname, String? location}) => {
        'species': species,
        'common_name': commonName,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (nickname != null && nickname.trim().isNotEmpty) 'nickname': nickname.trim(),
        if (location != null && location.trim().isNotEmpty) 'location': location.trim(),
        if (careSchedule.isNotEmpty) 'care_schedule': careSchedule,
      };
}
