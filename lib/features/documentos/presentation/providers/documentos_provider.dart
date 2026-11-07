import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/documentos_remote_datasource.dart';
import '../../data/models/documento_model.dart';
import '../../data/models/tipo_documento_model.dart';

/// Proveedor para listar los tipos de documentos disponibles
final tiposDocumentosListProvider =
    FutureProvider<List<TipoDocumentoModel>>((ref) async {
  final dataSource = ref.watch(documentosRemoteDataSourceProvider);
  return dataSource.getTiposDocumento();
});

/// Notifier para la lista principal de documentos del usuario
class DocumentosListNotifier extends AsyncNotifier<List<DocumentoModel>> {
  @override
  Future<List<DocumentoModel>> build() async {
    final dataSource = ref.watch(documentosRemoteDataSourceProvider);
    return dataSource.getDocumentos();
  }

  /// Recarga forzada de la lista de documentos
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dataSource = ref.read(documentosRemoteDataSourceProvider);
      return dataSource.getDocumentos();
    });
  }

  /// Sube un nuevo documento y actualiza la lista localmente
  Future<DocumentoModel> uploadDocumento({
    required int idTipoDocumento,
    required String filePath,
    required String fileName,
    String? titulo,
  }) async {
    final dataSource = ref.read(documentosRemoteDataSourceProvider);
    final nuevoDoc = await dataSource.uploadDocumento(
      idTipoDocumento: idTipoDocumento,
      filePath: filePath,
      fileName: fileName,
      titulo: titulo,
    );

    // Actualizar lista en estado local insertando al inicio
    final currentList = state.value ?? [];
    state = AsyncValue.data([nuevoDoc, ...currentList]);

    return nuevoDoc;
  }

  /// Elimina un documento por ID
  Future<void> deleteDocumento(int id) async {
    final dataSource = ref.read(documentosRemoteDataSourceProvider);
    await dataSource.deleteDocumento(id);

    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.where((doc) => doc.id != id).toList(),
    );
  }
}

final documentosListProvider =
    AsyncNotifierProvider<DocumentosListNotifier, List<DocumentoModel>>(
  DocumentosListNotifier.new,
);

/// Notifier para el término de búsqueda
class DocumentosSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) => state = query;
}

final documentosSearchProvider =
    NotifierProvider<DocumentosSearchNotifier, String>(
  DocumentosSearchNotifier.new,
);

/// Notifier para el filtro por tipo de documento (null = todos)
class DocumentosTipoFiltroNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setTipo(int? tipoId) => state = tipoId;
}

final documentosTipoFiltroProvider =
    NotifierProvider<DocumentosTipoFiltroNotifier, int?>(
  DocumentosTipoFiltroNotifier.new,
);

/// Proveedor computado que entrega la lista de documentos filtrados
final filteredDocumentosProvider =
    Provider<AsyncValue<List<DocumentoModel>>>((ref) {
  final docsAsync = ref.watch(documentosListProvider);
  final searchQuery = ref.watch(documentosSearchProvider).trim().toLowerCase();
  final selectedTipoId = ref.watch(documentosTipoFiltroProvider);

  return docsAsync.whenData((docs) {
    return docs.where((doc) {
      // Filtro por tipo
      if (selectedTipoId != null && doc.idTipoDocumento != selectedTipoId) {
        return false;
      }

      // Filtro por búsqueda textual
      if (searchQuery.isNotEmpty) {
        final title = doc.displayTitle.toLowerCase();
        final tipo = doc.displayTipoNombre.toLowerCase();
        final matches = title.contains(searchQuery) || tipo.contains(searchQuery);
        if (!matches) return false;
      }

      return true;
    }).toList();
  });
});
