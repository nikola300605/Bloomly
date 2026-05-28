import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/scan_result_model.dart';
import '../../../data/repositories/scan_repository.dart';

class ScanState {
  final bool loading;
  final ScanResultModel? result;
  final String? error;

  const ScanState({this.loading = false, this.result, this.error});

  ScanState copyWith({bool? loading, ScanResultModel? result, String? error}) => ScanState(
        loading: loading ?? this.loading,
        result: result ?? this.result,
        error: error,
      );
}

class ScanNotifier extends StateNotifier<ScanState> {
  final ScanRepository _repo;
  ScanNotifier(this._repo) : super(const ScanState());

  Future<ScanResultModel?> identify(File imageFile) async {
    state = const ScanState(loading: true);
    try {
      final result = await _repo.identify(imageFile);
      state = ScanState(result: result);
      return result;
    } catch (e) {
      state = ScanState(error: e.toString());
      return null;
    }
  }

  Future<ScanResultModel?> diagnose({
    required File imageFile,
    required List<String> symptoms,
    String? plantId,
  }) async {
    state = const ScanState(loading: true);
    try {
      final result = await _repo.diagnose(imageFile: imageFile, symptoms: symptoms, plantId: plantId);
      state = ScanState(result: result);
      return result;
    } catch (e) {
      state = ScanState(error: e.toString());
      return null;
    }
  }

  void reset() => state = const ScanState();
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref.read(scanRepositoryProvider));
});
