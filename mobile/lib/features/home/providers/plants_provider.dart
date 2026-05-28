import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/plant_model.dart';
import '../../../data/repositories/plant_repository.dart';

final plantsProvider = FutureProvider<List<PlantModel>>((ref) {
  return ref.read(plantRepositoryProvider).listPlants();
});

final plantDetailProvider = FutureProvider.family<PlantModel, String>((ref, plantId) {
  return ref.read(plantRepositoryProvider).getPlant(plantId);
});
