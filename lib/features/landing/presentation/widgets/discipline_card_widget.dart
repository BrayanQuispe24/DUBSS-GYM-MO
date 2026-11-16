import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/discipline_model.dart';

class DisciplineCardWidget extends StatelessWidget {
  final DisciplineModel discipline;
  final VoidCallback? onSelect;

  const DisciplineCardWidget({
    super.key,
    required this.discipline,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(4),
          hoverColor: AppColors.surfaceHover,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen con badge de categoría institucional
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: discipline.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.carbonSurfaceMuted,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryCrimson),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.carbonSurfaceMuted,
                          child: const Icon(Icons.fitness_center, color: AppColors.textSlateMuted, size: 36),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCrimson,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accentVibrant, width: 0.8),
                        ),
                        child: Text(
                          discipline.categoryLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido de la tarjeta (Título, Descripción y Tags)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discipline.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      discipline.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSlateLight,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tags descriptivos técnicos
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: discipline.tags.take(3).map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.carbonSurfaceMuted,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSlateMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
