import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/complejos_controller.dart';
import '../widgets/complejo_card.dart';
import '../widgets/formato_filter_bar.dart';

class ComplejosListPage extends ConsumerWidget {
  const ComplejosListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complejosAsync = ref.watch(complejosListProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'CAIMANEROS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDarkLighter,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.borderColor, width: 1.0),
              ),
              child: const Text(
                'BOOKING',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Botón para alternar a Vista Mapa
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Ver en Mapa',
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor, width: 1.0),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 18,
                  color: AppTheme.primaryGreen,
                ),
              ),
              onPressed: () => context.go(AppRoutes.mapa),
            ),
          ),

          // Botón de Cerrar Sesión
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Cerrar Sesión',
              icon: const Icon(
                Icons.logout,
                size: 20,
                color: AppTheme.textMuted,
              ),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de Bienvenida y Rol
          if (authState is AuthAuthenticated)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Hola, ${authState.perfil.nombre}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.borderColor, width: 1.0),
                    ),
                    child: Text(
                      authState.perfil.rol.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Barra de Filtros de Formato
          const FormatoFilterBar(),
          const SizedBox(height: 12),

          // Lista de Complejos Deportivos
          Expanded(
            child: complejosAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Error al cargar complejos: $err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => ref.refresh(complejosListProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (complejos) {
                if (complejos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sports_soccer,
                            size: 48,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No se encontraron complejos para este formato',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Prueba seleccionando otro formato o restablece a "Todos"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              ref.read(formatoFiltroProvider.notifier).state = null;
                            },
                            child: const Text('Restablecer Filtros'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  backgroundColor: AppTheme.surfaceDark,
                  onRefresh: () async => ref.refresh(complejosListProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: complejos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final complejo = complejos[index];
                      return ComplejoCard(
                        complejo: complejo,
                        onTap: () => context.go('/complejos/${complejo.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
