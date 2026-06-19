import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/theme.dart';

class LocationPicker extends StatefulWidget {
  final void Function(double latitude, double longitude) onLocationChanged;

  const LocationPicker({
    super.key,
    required this.onLocationChanged,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  static const double _defaultLat = -6.9175;
  static const double _defaultLng = 107.6191;

  final mapController = MapController();
  LatLng _center = const LatLng(_defaultLat, _defaultLng);
  LatLng _selectedLocation = const LatLng(_defaultLat, _defaultLng);

  @override
  void initState() {
    super.initState();
    widget.onLocationChanged(_defaultLat, _defaultLng);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onVerticalDragUpdate: (_) {},
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightGrey),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 14,
                    minZoom: 5,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                        _center = point;
                      });
                      widget.onLocationChanged(point.latitude, point.longitude);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.liquidpedia.liquid_mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: _selectedLocation,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                    ),
                    child: Text('Tap peta untuk pilih lokasi', style: TextStyle(fontSize: 11, color: AppTheme.accent)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
          style: TextStyle(color: AppTheme.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () {
            mapController.move(_selectedLocation, 16);
          },
          icon: const Icon(Icons.my_location, size: 16),
          label: const Text('Pusatkan ke lokasi terpilih'),
        ),
      ],
    );
  }
}
