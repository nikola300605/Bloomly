import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/scan_result_model.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(ref.read(apiClientProvider));
});

class ScanRepository {
  final ApiClient _api;
  ScanRepository(this._api);

  Future<ScanResultModel> identify(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: 'plant.jpg'),
    });
    final res = await _api.post('/scan/identify', formData: formData);
    return ScanResultModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ScanResultModel> diagnose({
    required File imageFile,
    required List<String> symptoms,
    String? plantId,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: 'leaf.jpg'),
      'symptoms': symptoms.join(','),
      if (plantId != null) 'plant_id': plantId,
    });
    final res = await _api.post('/scan/diagnose', formData: formData);
    return ScanResultModel.fromJson(res.data as Map<String, dynamic>);
  }
}
