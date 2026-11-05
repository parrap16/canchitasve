import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_map_widget.dart';
import '../../domain/entities/complejo_deportivo.dart';
import '../controllers/complejos_controller.dart';
import '../widgets/formato_filter_bar.dart';

class ComplejosMapPage extends ConsumerStatefulWidget {
  const ComplejosMapPage({super.key});

  @override
  ConsumerState<ComplejosMapPage> createState() => _ComplejosMapPageState();
}

class _ComplejosMapPageState extends ConsumerState<ComplejosMapPage> {
  GoogleMapController? _mapController;

  // Centro inicial: Maracaibo, Zulia
  static const LatLng _maracaiboDefault = LatLng(10.6558, -71.6350);

  void _onMarkerTapped(ComplejoDeportivo complejo) {
    ref.read(complejoSeleccionadoProvider.notifier).state = complejo;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(complejo.latitud, complejo.longitud),
        15.5,
      ),
    );
  }

  Set<Marker> _buildMarkers(List<ComplejoDeportivo> complejos) {
    return complejos.map((c) {
      return Marker(
        markerId: MarkerId(c.id),
        position: LatLng(c.latitud, c.longitud),
        infoWindow: InfoWindow(
          title: c.nombre,
          snippet: 'Desde \$${c.precioBase.toStringAsFixed(0)}/h · ${c.formatosBadge}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () => _onMarkerTapped(c),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final complejosAsync = ref.watch(complejosListProvider);
    final selectedComplejo = ref.watch(complejoSeleccionadoProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Mapa en pantalla completa
          complejosAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            ),
            error: (err, _) => Center(
              child: Text(
                'Error al cargar mapa: $err',
                style: const TextStyle(color: AppTheme.error),
              ),
            ),
            data: (complejos) {
              final markers = _buildMarkers(complejos);
              final initialPos = complejos.isNotEmpty
                  ? LatLng(complejos.first.latitud, complejos.first.longitud)
                  : _maracaiboDefault;

              return AppMapWidget(
                initialPosition: initialPos,
                initialZoom: 13.0,
                markers: markers,
                interactive: true,
                onMapCreated: (controller) => _mapController = controller,
                onTap: (_) {
                  // Deseleccionar al tocar fuera
                  ref.read(complejoSeleccionadoProvider.notifier).state = null;
                },
              );
            },
          ),

          // Header Flotante Minimalista: Botón volver + Barra de Filtros
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Botón volver a lista
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.home),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundDark.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderColor, width: 1.0),
                          ),
                          child: const Icon(
                            Icons.format_list_bulleted,
                            size: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Título flotante
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundDark.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderColor, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.pin_drop,
                                size: 16,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Canchas en Maracaibo',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              complejosAsync.maybeWhen(
                                data: (list) => Text(
                                  '${list.length} complejos',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                orElse: () => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Filtro flotante
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor, width: 1.0),
                    ),
                    child: const FormatoFilterBar(),
                  ),
                ],
              ),
            ),
          ),

          // Tarjeta Flotante Inferior de Vista Previa al seleccionar un Complejo
          if (selectedComplejo != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _ComplejoMapPreviewCard(
                complejo: selectedComplejo,
                onClose: () {
                  ref.read(complejoSeleccionadoProvider.notifier).state = null;
                },
                onViewDetail: () {
                  context.go('/complejos/${selectedComplejo.id}');
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ComplejoMapPreviewCard extends StatelessWidget {
  const _ComplejoMapPreviewCard({
    required this.complejo,
    required this.onClose,
    required this.onViewDetail,
  });

  final ComplejoDeportivo complejo;
  final VoidCallback onClose;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de formato
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDarkLighter,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.borderColor, width: 1.0),
                ),
                child: Text(
                  complejo.formatosBadge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Nombre del complejo
              Expanded(
                child: Text(
                  complejo.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Botón cerrar
              GestureDetector(
                onTap: onClose,
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dirección
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  complejo.direccion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Precio y botón de detalle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tarifa base',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    '\$${complejo.precioBase.toStringAsFixed(0)} / hora',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onViewDetail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ver Canchas', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
