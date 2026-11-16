import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DocumentosEmptyView extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onClearFilter;
  final VoidCallback onUploadPressed;

  const DocumentosEmptyView({
    super.key,
    required this.isFiltered,
    required this.onClearFilter,
    required this.onUploadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.carbonSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.folder_open_outlined,
                size: 36,
                color: AppColors.accentVibrant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered
                  ? 'No se encontraron documentos'
                  : 'Sin documentos digitales aún',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Intenta con otro término de búsqueda o cambia el filtro de categoría.'
                  : 'Sube tus certificados médicos, matrícula universitaria o respaldos de trámites.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSlateMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (isFiltered)
              OutlinedButton.icon(
                onPressed: onClearFilter,
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('Limpiar Filtros'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentVibrant,
                  side: const BorderSide(color: AppColors.accentVibrant),
                  backgroundColor: AppColors.carbonSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: onUploadPressed,
                icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                label: const Text('Subir Primer Documento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCrimson,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
