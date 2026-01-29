import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class IssueMapScreen extends StatefulWidget {
  const IssueMapScreen({super.key});

  @override
  State<IssueMapScreen> createState() => _IssueMapScreenState();
}

class _IssueMapScreenState extends State<IssueMapScreen> {
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  Future<void> loadMarkers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('issues').get();

    List<Marker> loadedMarkers = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data['lat'] == null || data['lng'] == null) continue;

      loadedMarkers.add(
        Marker(
          point: LatLng(data['lat'], data['lng']),
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_pin,
            color: getMarkerColor(data['title']),
            size: 40,
          ),
        ),
      );
    }

    setState(() => _markers.addAll(loadedMarkers));
  }

  Color getMarkerColor(String category) {
    switch (category.toLowerCase()) {
      case 'pothole':
        return Colors.orange;
      case 'garbage':
        return Colors.green;
      case 'water':
        return Colors.blue;
      case 'electricity':
        return Colors.purple;
      case 'crime':
        return Colors.red;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌍 Live Issue Map"),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(22.5937, 78.9629), // India Center
          initialZoom: 5.3,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.civic_ai_app',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
