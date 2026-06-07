import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/species_model.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.read(apiClientProvider));
});

class CatalogRepository {
  final ApiClient _api;
  CatalogRepository(this._api);

  Future<List<SpeciesModel>> listCatalog({String? q}) async {
    final res = await _api.get(
      '/catalog/',
      queryParameters: {if (q != null && q.isNotEmpty) 'q': q},
    );
    return (res.data as List)
        .map((e) => SpeciesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
