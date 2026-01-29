import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:civic_ai_app/services/ai_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final TextEditingController _descController = TextEditingController();

  // 🏢 NEW CONTROLLERS
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool _loading = false;

  final String cloudName = "dpzn34hwx";
  final String uploadPreset = "civic_ai_upload";

  Future<void> _pickImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<Position> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Please enable location services';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw 'Location permission denied';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> _getAddress(Position pos) async {
    final placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    final place = placemarks.first;
    return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
  }

  Future<String> _uploadToCloudinary(File image) async {
    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    return json.decode(resStr)['secure_url'];
  }

  String getDepartment(String category) {
    switch (category.toLowerCase()) {
      case 'crime':
        return 'Police Department';
      case 'garbage':
        return 'Municipal Sanitation Department';
      case 'road':
      case 'pothole':
        return 'Road & Transport Department';
      default:
        return 'General Municipal Department';
    }
  }

  int getExpectedHours(String category) {
    switch (category.toLowerCase()) {
      case 'crime':
        return 1;
      case 'garbage':
        return 24;
      case 'road':
      case 'pothole':
        return 72;
      default:
        return 48;
    }
  }

  Future<void> _submitIssue() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("📧 Please verify your email to report an issue")),
      );
      return;
    }


    if (_descController.text.trim().isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("⚠️ Please add description and photo")),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      final pos = await _getLocation();
      final address = await _getAddress(pos);
      final imageUrl = await _uploadToCloudinary(_image!);

      final ai = await AIService().classifyIssue(_descController.text);
      final dept = getDepartment(ai['category']);

      final now = DateTime.now();
      final expectedHours = getExpectedHours(ai['category']);
      final expectedResolution =
          now.add(Duration(hours: expectedHours));

      await FirebaseFirestore.instance.collection('issues').add({
        'title': ai['category'],
        'description': _descController.text,
        'summary': ai['summary'] ?? '',
        'urgency': ai['urgency'] ?? 'Low',
        'department': dept,

        'imageUrl': imageUrl,
        'location': address,
        'lat': pos.latitude,
        'lng': pos.longitude,

        // 🏢 NEW LOCATION DETAILS
        'building': _buildingController.text.trim(),
        'room': _roomController.text.trim(),
        'landmark': _landmarkController.text.trim(),

        'status': 'Pending',
        'userId': user.uid,
        'userEmail': user.email,

        'reportedAt': Timestamp.fromDate(now),
        'expectedResolutionAt':
            Timestamp.fromDate(expectedResolution),
        'expectedHours': expectedHours,

        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("✅ Issue reported with exact location details")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report an Issue")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: "Describe the issue"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _buildingController,
              decoration: const InputDecoration(
                  labelText: "🏢 Building / Society"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _roomController,
              decoration:
                  const InputDecoration(labelText: "🚪 Room / Floor"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _landmarkController,
              decoration:
                  const InputDecoration(labelText: "📍 Nearby Landmark"),
            ),

            const SizedBox(height: 15),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image == null
                    ? const Center(
                        child: Icon(Icons.camera_alt, size: 40))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: _loading ? null : _submitIssue,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Issue"),
            ),
          ],
        ),
      ),
    );
  }
}
