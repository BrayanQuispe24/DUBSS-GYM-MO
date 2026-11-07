import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EjercicioDetailModal(ejercicio: ejercicio),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipoNombre = ejercicio.tipoEjercicio?.nombre ?? 'General';
    final hasImages = ejercicio.imagenes.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
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
                      color: const Color(0xFF0077D4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
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
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Tipo: $tipoNombre',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0077D4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Content List
            Expanded(
              child: ListView(
                controller: scrollController,
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
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library, color: Color(0xFF0077D4), size: 22),
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
                                      color: Color(0xFF0077D4),
                                    ),
                                  ),
                                  const Text(
                                    'Ver posturas paso a paso en pantalla completa',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF0077D4)),
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
                        color: Color(0xFF0F172A),
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
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            g.nombre,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
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
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      ejercicio.descripcion?.isNotEmpty == true
                          ? ejercicio.descripcion!
                          : 'No se registraron instrucciones específicas para este movimiento.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF334155),
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
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_fill, color: Color(0xFFD97706), size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Video disponible: ${ejercicio.urlVideo}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0077D4)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
