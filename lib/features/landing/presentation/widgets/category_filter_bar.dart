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

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
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
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryRed : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryRed : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
      ),
    );
  }
}
