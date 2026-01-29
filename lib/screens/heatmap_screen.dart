import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HeatMapScreen extends StatefulWidget {
  const HeatMapScreen({super.key});

  @override
  State<HeatMapScreen> createState() => _HeatMapScreenState();
}

class _HeatMapScreenState extends State<HeatMapScreen> {
  List<CircleMarker> circles = [];

  @override
  void initState() {
    super.initState();
    fetchHeatMapData();
  }

  Future<void> fetchHeatMapData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('heatmap').get();

    List<CircleMarker> temp = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      double lat = data['lat'];
      double lng = data['lng'];
      int severity = data['severity'];

      temp.add(
        CircleMarker(
          point: LatLng(lat, lng),
          radius: severity * 10.0,
          color: getHeatColor(severity).withOpacity(0.45),
          borderStrokeWidth: 1,
          borderColor: getHeatColor(severity),
        ),
      );
    }

    setState(() {
      circles = temp;
    });
  }

  Color getHeatColor(int severity) {
    if (severity >= 4) return Colors.red;
    if (severity == 3) return Colors.orange;
    return Colors.yellow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔥 Emergency Heat Map"),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(22.9734, 78.6569), // India center
          initialZoom: 5.5,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.civic_ai_app',
          ),
          CircleLayer(circles: circles),
        ],
      ),
    );
  }
}
