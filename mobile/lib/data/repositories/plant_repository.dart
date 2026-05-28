import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/plant_model.dart';

final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  return PlantRepository(ref.read(apiClientProvider));
});

class PlantRepository {
  final ApiClient _api;
  PlantRepository(this._api);

  Future<List<PlantModel>> listPlants() async {
    final res = await _api.get('/plants/');
    return (res.data as List).map((e) => PlantModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PlantModel> getPlant(String plantId) async {
    final res = await _api.get('/plants/$plantId');
    return PlantModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PlantModel> createPlant(Map<String, dynamic> data) async {
    final res = await _api.post('/plants/', data: data);
    return PlantModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PlantModel> updatePlant(String plantId, Map<String, dynamic> data) async {
    final res = await _api.patch('/plants/$plantId', data: data);
    return PlantModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deletePlant(String plantId) => _api.delete('/plants/$plantId');

  Future<void> markCareDone(String plantId, String kind) async {
    await _api.post('/plants/$plantId/care/done', data: {'plant_id': plantId, 'kind': kind});
  }

  Future<void> snooze(String plantId, String kind, {int snoozeDays = 1}) async {
    await _api.post('/plants/$plantId/care/snooze', data: {
      'plant_id': plantId,
      'kind': kind,
      'snooze_days': snoozeDays,
    });
  }

  Future<List<Map<String, dynamic>>> getCareTasksAll() async {
    final res = await _api.get('/plants/care/tasks');
    return List<Map<String, dynamic>>.from(res.data as List);
  }
}
