import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/documento_model.dart';
import '../screens/documento_preview_screen.dart';

class DocumentoCard extends StatelessWidget {
  final DocumentoModel documento;
  final VoidCallback onDelete;

  const DocumentoCard({
    super.key,
    required this.documento,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = documento.isPdf;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => DocumentoPreviewScreen.open(context, documento),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isPdf
                        ? AppColors.accentVibrant.withValues(alpha: 0.15)
                        : AppColors.carbonSurfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isPdf ? AppColors.accentVibrant : AppColors.borderSubtle,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                      color: isPdf ? AppColors.accentVibrant : AppColors.solarAmber,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documento.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.carbonSurfaceMuted,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.borderSubtle,
                              ),
                            ),
                            child: Text(
                              documento.displayTipoNombre,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSlateLight,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 11.5,
                                color: AppColors.textSlateMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                documento.formattedDate,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSlateMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing Action Menu
                PopupMenuButton<String>(
                  color: AppColors.carbonSurface,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textSlateMuted,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  onSelected: (value) {
                    if (value == 'view') {
                      DocumentoPreviewScreen.open(context, documento);
                    } else if (value == 'delete') {
                      _confirmDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 18, color: AppColors.accentVibrant),
                          SizedBox(width: 8),
                          Text('Ver Documento', style: TextStyle(fontSize: 13, color: AppColors.textWhite)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.accentVibrant),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(fontSize: 13, color: AppColors.accentVibrant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.carbonSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.accentVibrant),
            SizedBox(width: 8),
            Text(
              'Eliminar Documento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textWhite),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${documento.displayTitle}"? Esta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textSlateLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSlateMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentVibrant,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
