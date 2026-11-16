import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/landing_providers.dart';

class CategoryFilterBar extends ConsumerWidget {
  const CategoryFilterBar({super.key});

  static const categories = [
    {'id': 'all', 'label': 'Todas las Áreas', 'icon': Icons.fitness_center},
    {'id': 'aparatos', 'label': 'Musculación', 'icon': Icons.sports_gymnastics},
    {'id': 'boxeo', 'label': 'Boxeo', 'icon': Icons.sports_mma},
    {'id': 'kickboxing', 'label': 'Kick Boxing', 'icon': Icons.sports_kabaddi},
    {'id': 'funcional', 'label': 'Funcional & TRX', 'icon': Icons.timer},
    {'id': 'baile', 'label': 'Baile & Ritmo', 'icon': Icons.music_note},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeCategoryProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = active == cat['id'];
          final iconData = cat['icon'] as IconData;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                ref
                    .read(activeCategoryProvider.notifier)
                    .setCategory(cat['id'] as String);
              },
              borderRadius: BorderRadius.circular(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryCrimson : AppColors.carbonSurface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? AppColors.accentVibrant : AppColors.borderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconData,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.textSlateMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSlateLight,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
