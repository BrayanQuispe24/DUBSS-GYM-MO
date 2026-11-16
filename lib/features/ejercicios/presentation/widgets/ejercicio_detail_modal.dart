import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ejercicio_model.dart';
import 'ejercicio_galeria_modal.dart';

class EjercicioDetailModal extends StatelessWidget {
  final EjercicioModel ejercicio;

  const EjercicioDetailModal({
    super.key,
    required this.ejercicio,
  });

  static Future<void> show(BuildContext context, EjercicioModel ejercicio) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EjercicioDetailModal(ejercicio: ejercicio),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipoNombre = ejercicio.tipoEjercicio?.nombre ?? 'General';
    final hasImages = ejercicio.imagenes.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          left: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          right: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Icons.fitness_center, color: AppColors.accentVibrant, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ejercicio.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Text(
                          'Tipo: $tipoNombre',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.solarGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSlateMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),

            // Content List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Specs Grid Cards
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildSpecBox(
                        title: 'EQUIPAMIENTO',
                        value: ejercicio.equipamiento ?? 'No especificado',
                        icon: Icons.hardware,
                      ),
                      _buildSpecBox(
                        title: 'DIFICULTAD',
                        value: ejercicio.nivelDificultad ?? 'General',
                        icon: Icons.trending_up,
                      ),
                      if (ejercicio.patronMovimiento != null)
                        _buildSpecBox(
                          title: 'PATRÓN',
                          value: ejercicio.patronMovimiento!,
                          icon: Icons.alt_route,
                        ),
                      if (ejercicio.mecanica != null)
                        _buildSpecBox(
                          title: 'MECÁNICA',
                          value: ejercicio.mecanica!,
                          icon: Icons.settings,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Galería Button Banner
                  if (hasImages)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        EjercicioGaleriaModal.show(context, ejercicio);
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.carbonSurfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accentVibrant),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library, color: AppColors.accentVibrant, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Demostración Visual (${ejercicio.imagenes.length} imágenes)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.accentVibrant,
                                    ),
                                  ),
                                  const Text(
                                    'Ver posturas paso a paso en pantalla completa',
                                    style: TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.accentVibrant),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Grupos Musculares
                  if (ejercicio.gruposMusculares.isNotEmpty) ...[
                    const Text(
                      'Grupos Musculares Involucrados',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: ejercicio.gruposMusculares.map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.carbonSurfaceMuted,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            g.nombre,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSlateLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Instrucciones / Descripción
                  const Text(
                    'Técnica de Ejecución & Instrucciones',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      ejercicio.descripcion?.isNotEmpty == true
                          ? ejercicio.descripcion!
                          : 'No se registraron instrucciones específicas para este movimiento.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSlateLight,
                        height: 1.5,
                      ),
                    ),
                  ),

                  // URL de Video if available
                  if (ejercicio.urlVideo != null && ejercicio.urlVideo!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.videocam, color: AppColors.accentVibrant, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Video disponible: ${ejercicio.urlVideo}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.accentVibrant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.carbonSurfaceMuted,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.accentVibrant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSlateMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}
