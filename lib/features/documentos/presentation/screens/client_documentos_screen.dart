import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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
          backgroundColor: AppColors.successEmerald,
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
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documentación Digital',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textWhite,
              ),
            ),
            Text(
              'Repositorio institucional de respaldos',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSlateMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.accentVibrant,
            ),
            tooltip: 'Refrescar',
            onPressed: () =>
                ref.read(documentosListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Búsqueda
          Container(
            color: AppColors.obsidianBase,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
              onChanged: (val) {
                ref.read(documentosSearchProvider.notifier).setSearch(val);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por título o categoría...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSlateMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSlateMuted,
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textSlateMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(documentosSearchProvider.notifier)
                              .setSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                filled: true,
                fillColor: AppColors.carbonSurfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.accentVibrant,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Chips de categorías / tipos de documentos
          Container(
            color: AppColors.obsidianBase,
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

          const Divider(height: 1, color: AppColors.borderSubtle),

          // Lista de documentos
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentVibrant,
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.accentVibrant,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Error al cargar documentos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        err
                            .toString()
                            .replaceAll('Exception: ', '')
                            .replaceAll('AppException: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSlateMuted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(documentosListProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryCrimson,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (documentos) {
                if (documentos.isEmpty) {
                  final isFiltered =
                      searchQuery.isNotEmpty || selectedTipoId != null;
                  return DocumentosEmptyView(
                    isFiltered: isFiltered,
                    onClearFilter: () {
                      _searchController.clear();
                      ref.read(documentosSearchProvider.notifier).setSearch('');
                      ref
                          .read(documentosTipoFiltroProvider.notifier)
                          .setTipo(null);
                    },
                    onUploadPressed: _openUploadSheet,
                  );
                }

                return RefreshIndicator(
                  color: AppColors.accentVibrant,
                  backgroundColor: AppColors.carbonSurface,
                  onRefresh: () =>
                      ref.read(documentosListProvider.notifier).refresh(),
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
                                  backgroundColor: AppColors.carbonSurfaceMuted,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al eliminar: $e'),
                                  backgroundColor: AppColors.accentVibrant,
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
        backgroundColor: AppColors.primaryCrimson,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
        ),
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
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryCrimson
                : AppColors.carbonSurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentVibrant
                  : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSlateLight,
            ),
          ),
        ),
      ),
    );
  }
}
