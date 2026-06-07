import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/species_model.dart';
import '../../../data/repositories/catalog_repository.dart';

/// The full plant catalog, fetched once. Search filters this list client-side.
final catalogProvider = FutureProvider<List<SpeciesModel>>((ref) {
  return ref.read(catalogRepositoryProvider).listCatalog();
});
