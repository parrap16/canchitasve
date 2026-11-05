import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/app_theme.dart';

/// Estilo JSON oscuro mate minimalista para Google Maps.
/// Diseñado para integrarse perfectamente con la paleta oscura de CAIMANEROS.
const String _matteDarkMapStyle = '''[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#181a19"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#181a19"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#2c312e"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#1f2321"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#13231a"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#242826"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{"color": "#2d3330"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#383f3b"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0d1310"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3d4742"}]
  }
]''';

/// Widget de mapa reutilizable para CAIMANEROS.
///
/// Soporta tanto vista completa interactiva como fragmentos compactos (preview).
/// Mantiene bordes finos de 1px y estética mate sin sombras.
class AppMapWidget extends StatefulWidget {
  const AppMapWidget({
    super.key,
    required this.initialPosition,
    this.initialZoom = 14.5,
    this.markers = const <Marker>{},
    this.interactive = true,
    this.height,
    this.onMapCreated,
    this.onTap,
  });

  final LatLng initialPosition;
  final double initialZoom;
  final Set<Marker> markers;
  final bool interactive;
  final double? height;
  final void Function(GoogleMapController controller)? onMapCreated;
  final void Function(LatLng position)? onTap;

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleMapCreated(GoogleMapController controller) {
    _controller = controller;
    widget.onMapCreated?.call(controller);
  }

  @override
  void didUpdateWidget(covariant AppMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markers != widget.markers) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget mapContent = GoogleMap(
      style: _matteDarkMapStyle,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers,
      onMapCreated: _handleMapCreated,
      onTap: widget.onTap,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      rotateGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: widget.interactive,
    );

    if (widget.height != null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: mapContent,
      );
    }

    return mapContent;
  }
}
