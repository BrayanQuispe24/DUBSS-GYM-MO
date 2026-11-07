import 'package:flutter/material.dart';

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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.folder_open_outlined,
                size: 38,
                color: const Color(0xFF64748B),
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
                color: Color(0xFF0F172A),
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
                color: Color(0xFF64748B),
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
                  foregroundColor: const Color(0xFF003B70),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: onUploadPressed,
                icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                label: const Text('Subir Primer Documento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B70),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
