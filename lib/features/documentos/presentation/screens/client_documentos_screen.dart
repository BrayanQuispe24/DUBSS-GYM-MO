import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/documentos_provider.dart';
import '../widgets/documento_card.dart';
import '../widgets/documento_upload_sheet.dart';
import '../widgets/documentos_empty_view.dart';

class ClientDocumentosScreen extends ConsumerStatefulWidget {
  const ClientDocumentosScreen({super.key});

  @override
  ConsumerState<ClientDocumentosScreen> createState() =>
      _ClientDocumentosScreenState();
}

class _ClientDocumentosScreenState
    extends ConsumerState<ClientDocumentosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openUploadSheet() async {
    final uploaded = await DocumentoUploadSheet.show(context);
    if (uploaded == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Documento subido exitosamente'),
            ],
          ),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredDocumentosProvider);
    final tiposAsync = ref.watch(tiposDocumentosListProvider);
    final selectedTipoId = ref.watch(documentosTipoFiltroProvider);
    final searchQuery = ref.watch(documentosSearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documentación Digital',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Repositorio institucional de respaldos',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF003B70)),
            tooltip: 'Refrescar',
            onPressed: () => ref.read(documentosListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Búsqueda
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(documentosSearchProvider.notifier).setSearch(val);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por título o categoría...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(documentosSearchProvider.notifier).setSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Chips de categorías / tipos de documentos
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            child: tiposAsync.when(
              data: (tipos) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildTipoChip(
                      label: 'Todos',
                      isSelected: selectedTipoId == null,
                      onTap: () {
                        ref
                            .read(documentosTipoFiltroProvider.notifier)
                            .setTipo(null);
                      },
                    ),
                    ...tipos.map((t) {
                      final isSelected = selectedTipoId == t.id;
                      return _buildTipoChip(
                        label: t.nombre,
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(documentosTipoFiltroProvider.notifier)
                              .setTipo(isSelected ? null : t.id);
                        },
                      );
                    }),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 36),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Lista de documentos
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF003B70)),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Color(0xFFDC2626),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Error al cargar documentos',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        err.toString().replaceAll('Exception: ', '').replaceAll('AppException: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => ref.read(documentosListProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003B70),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (documentos) {
                if (documentos.isEmpty) {
                  final isFiltered = searchQuery.isNotEmpty || selectedTipoId != null;
                  return DocumentosEmptyView(
                    isFiltered: isFiltered,
                    onClearFilter: () {
                      _searchController.clear();
                      ref.read(documentosSearchProvider.notifier).setSearch('');
                      ref.read(documentosTipoFiltroProvider.notifier).setTipo(null);
                    },
                    onUploadPressed: _openUploadSheet,
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF003B70),
                  onRefresh: () => ref.read(documentosListProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: documentos.length,
                    itemBuilder: (context, index) {
                      final doc = documentos[index];
                      return DocumentoCard(
                        documento: doc,
                        onDelete: () async {
                          try {
                            await ref
                                .read(documentosListProvider.notifier)
                                .deleteDocumento(doc.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Documento eliminado'),
                                  backgroundColor: Color(0xFF475569),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al eliminar: $e'),
                                  backgroundColor: const Color(0xFFDC2626),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadSheet,
        backgroundColor: const Color(0xFF003B70),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.cloud_upload_outlined, size: 20),
        label: const Text(
          'Subir PDF',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildTipoChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF003B70) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF003B70) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
