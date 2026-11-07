import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/ejercicio_model.dart';
import 'ejercicio_detail_modal.dart';
import 'ejercicio_galeria_modal.dart';

class EjercicioCardWidget extends StatelessWidget {
  final EjercicioModel ejercicio;

  const EjercicioCardWidget({
    super.key,
    required this.ejercicio,
  });

  @override
  Widget build(BuildContext context) {
    final tipoNombre = ejercicio.tipoEjercicio?.nombre ?? 'General';
    final hasImages = ejercicio.imagenes.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => EjercicioDetailModal.show(context, ejercicio),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Thumbnail + Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFFF1F5F9),
                        child: ejercicio.firstImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: ejercicio.firstImageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.fitness_center,
                                  color: Color(0xFF94A3B8),
                                  size: 28,
                                ),
                              )
                            : const Icon(
                                Icons.fitness_center,
                                color: Color(0xFF94A3B8),
                                size: 28,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Specs
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ejercicio.nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Text(
                              tipoNombre.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0077D4),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Equipment if present
                          if (ejercicio.equipamiento != null && ejercicio.equipamiento!.isNotEmpty)
                            Text(
                              'Equipamiento: ${ejercicio.equipamiento}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Muscle Groups Chips
                if (ejercicio.gruposMusculares.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: ejercicio.gruposMusculares.take(3).map((g) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          g.nombre,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (hasImages)
                      OutlinedButton.icon(
                        onPressed: () => EjercicioGaleriaModal.show(context, ejercicio),
                        icon: const Icon(Icons.photo_library_outlined, size: 14, color: Color(0xFF0077D4)),
                        label: Text(
                          'Galería (${ejercicio.imagenes.length})',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0077D4),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBAE6FD)),
                          backgroundColor: const Color(0xFFF0F7FF),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => EjercicioDetailModal.show(context, ejercicio),
                      icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.white),
                      label: const Text(
                        'Ver Ejercicio',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077D4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
}
