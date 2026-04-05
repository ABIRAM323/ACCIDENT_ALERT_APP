import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../models/hospital.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMarkers();
      _fitMarkersOnMap();
    });
  }

  void _setupMarkers() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final position = locationProvider.currentPosition;
    
    if (position == null) return;

    _markers.clear();

    // Add user location marker (Blue)
    _markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(position.latitude, position.longitude),
        child: const Column(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 40,
            ),
            Text(
              'You',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );

    // Add hospital markers
    for (int i = 0; i < locationProvider.nearbyHospitals.length; i++) {
      final hospital = locationProvider.nearbyHospitals[i];
      final isNearest = i == 0;
      
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(hospital.latitude, hospital.longitude),
          child: GestureDetector(
            onTap: () => _showHospitalInfo(hospital),
            child: Column(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: isNearest ? Colors.green : Colors.red,
                  size: 40,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    hospital.distanceText,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    setState(() {});
  }

  void _showHospitalInfo(Hospital hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.local_hospital, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hospital.name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.location_on, hospital.address),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.directions, hospital.distanceText),
            if (hospital.phoneNumber != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone, hospital.phoneNumber!),
            ],
            if (hospital.rating != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.star,
                '${hospital.rating!.toStringAsFixed(1)} ⭐',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _fitMarkersOnMap() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final position = locationProvider.currentPosition;
    
    if (position == null || locationProvider.nearbyHospitals.isEmpty) return;

    // Calculate bounds
    double minLat = position.latitude;
    double maxLat = position.latitude;
    double minLng = position.longitude;
    double maxLng = position.longitude;

    for (var hospital in locationProvider.nearbyHospitals) {
      if (hospital.latitude < minLat) minLat = hospital.latitude;
      if (hospital.latitude > maxLat) maxLat = hospital.latitude;
      if (hospital.longitude < minLng) minLng = hospital.longitude;
      if (hospital.longitude > maxLng) maxLng = hospital.longitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    // Add padding to bounds
    final paddedBounds = LatLngBounds(
      LatLng(bounds.south - 0.01, bounds.west - 0.01),
      LatLng(bounds.north + 0.01, bounds.east + 0.01),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: paddedBounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final position = locationProvider.currentPosition;

    if (position == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Map View'),
        ),
        body: const Center(
          child: Text('No location available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals Map'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(position.latitude, position.longitude),
                initialZoom: 14.0,
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                // OpenStreetMap Tile Layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.accident_alert_app',
                  maxZoom: 19,
                  subdomains: const ['a', 'b', 'c'],
                  tileProvider: NetworkTileProvider(),
                ),
                // Markers Layer
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
          
          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(
                      Colors.blue,
                      'Your Location',
                      Icons.location_on,
                    ),
                    _buildLegendItem(
                      Colors.green,
                      'Nearest Hospital',
                      Icons.local_hospital,
                    ),
                    _buildLegendItem(
                      Colors.red,
                      'Other Hospitals',
                      Icons.local_hospital,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
