import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/complejos_controller.dart';

class FormatoFilterBar extends ConsumerWidget {
  const FormatoFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFormato = ref.watch(formatoFiltroProvider);

    final filters = [
      (label: 'Todos', formato: null),
      (label: 'Fútbol 5 (F5)', formato: 5),
      (label: 'Fútbol 7 (F7)', formato: 7),
      (label: 'Fútbol 11 (F11)', formato: 11),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFormato == filter.formato;

          return GestureDetector(
            onTap: () {
              ref.read(formatoFiltroProvider.notifier).state = filter.formato;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.borderColor,
                  width: 1.0,
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF042F15)
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
