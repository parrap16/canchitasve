import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_map_widget.dart';
import '../../domain/entities/cancha.dart';
import '../controllers/complejos_controller.dart';

class ComplejoDetallePage extends ConsumerWidget {
  const ComplejoDetallePage({
    super.key,
    required this.complejoId,
  });

  final String complejoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complejoAsync = ref.watch(complejoDetalleProvider(complejoId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: complejoAsync.when(
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
                  'No se pudo cargar el complejo: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
        data: (complejo) {
          final position = LatLng(complejo.latitud, complejo.longitud);
          final markers = {
            Marker(
              markerId: MarkerId(complejo.id),
              position: position,
              infoWindow: InfoWindow(title: complejo.nombre),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          };

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // SliverAppBar con foto del complejo
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: AppTheme.backgroundDark,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundDark.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderColor, width: 1.0),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: complejo.fotoUrl != null && complejo.fotoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: complejo.fotoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppTheme.surfaceDark,
                                child: const Center(
                                  child: Icon(Icons.sports_soccer, size: 48, color: AppTheme.textMuted),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppTheme.surfaceDark,
                                child: const Center(
                                  child: Icon(Icons.stadium, size: 48, color: AppTheme.textMuted),
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.surfaceDark,
                              child: const Center(
                                child: Icon(Icons.stadium, size: 56, color: AppTheme.textMuted),
                              ),
                            ),
                    ),
                  ),

                  // Contenido de la información del complejo
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge de Formatos y Precio
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceDarkLighter,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.borderColor, width: 1.0),
                                ),
                                child: Text(
                                  complejo.formatosBadge,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Desde \$${complejo.precioBase.toStringAsFixed(0)} / hora',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Nombre del Complejo
                          Text(
                            complejo.nombre,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Dirección completa
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  complejo.direccion,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 20),

                          // Sección: Canchas Disponibles
                          Row(
                            children: [
                              const Text(
                                'Canchas Disponibles',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceDark,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.borderColor, width: 1.0),
                                ),
                                child: Text(
                                  '${complejo.canchas.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (complejo.canchas.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.borderColor, width: 1.0),
                              ),
                              child: const Text(
                                'No hay canchas registradas para este complejo en este momento.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: complejo.canchas.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final cancha = complejo.canchas[index];
                                return _CanchaItemCard(cancha: cancha, index: index + 1);
                              },
                            ),

                          const SizedBox(height: 28),

                          // Sección: Fragmento de Mapa de Ubicación
                          const Text(
                            'Ubicación',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          AppMapWidget(
                            initialPosition: position,
                            initialZoom: 15.0,
                            markers: markers,
                            interactive: false,
                            height: 180,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coordenadas: ${complejo.latitud.toStringAsFixed(5)}, ${complejo.longitud.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Barra de Acción Inferior Fija con Botón "Ver Horarios" (Deshabilitado temporalmente)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark.withValues(alpha: 0.95),
                    border: const Border(
                      top: BorderSide(color: AppTheme.borderColor, width: 1.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mensaje informativo Fase 1 -> Fase 2
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 13,
                            color: AppTheme.textMuted,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Módulo de calendario y reservas activará en Fase 2',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Botón deshabilitado temporalmente según requerimiento
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          // null deshabilita el botón según las directrices de Material
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.surfaceDarkLighter,
                            disabledBackgroundColor: AppTheme.surfaceDark,
                            disabledForegroundColor: AppTheme.textMuted,
                            side: const BorderSide(color: AppTheme.borderColor, width: 1.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Ver Horarios',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CanchaItemCard extends StatelessWidget {
  const _CanchaItemCard({
    required this.cancha,
    required this.index,
  });

  final Cancha cancha;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor, width: 1.0),
      ),
      child: Row(
        children: [
          // Número de cancha
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDarkLighter,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor, width: 1.0),
            ),
            child: Center(
              child: Text(
                '#$index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Formato y superficie
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cancha.formatoLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cancha.superficie.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Badge Techada o Al aire libre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDarkLighter,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.borderColor, width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cancha.techada ? Icons.roofing : Icons.wb_sunny_outlined,
                  size: 13,
                  color: cancha.techada ? AppTheme.primaryGreen : AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  cancha.techada ? 'Techada' : 'Al aire libre',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cancha.techada ? AppTheme.textPrimary : AppTheme.textSecondary,
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
