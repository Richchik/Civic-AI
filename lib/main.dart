import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:civic_ai_app/firebase_options.dart';
import 'package:civic_ai_app/issues_feed.dart';
import 'package:civic_ai_app/report_issue.dart';
import 'package:civic_ai_app/screens/login_screen.dart';
import 'package:civic_ai_app/screens/admin_dashboard.dart';
import 'package:civic_ai_app/screens/heatmap_screen.dart';
import 'package:civic_ai_app/screens/issue_map_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CivicAIApp());
}

class CivicAIApp extends StatelessWidget {
  const CivicAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Civic AI',
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboard(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CivicAI'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(   // 🔥 FIX
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.location_city, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text(
                'Welcome to CivicAI',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'AI-powered public issue reporting',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              /// Report Issue
              ElevatedButton.icon(
                icon: const Icon(Icons.report_problem),
                label: const Text('Report an Issue'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportIssueScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              /// View Live Issues
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('View Live Issues'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IssuesFeed(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              /// 🔥 Emergency Heat Map
              ElevatedButton.icon(
                icon: const Icon(Icons.local_fire_department),
                label: const Text('Emergency Heat Map'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HeatMapScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              /// 🗺 Live Issue Map  🔥🔥🔥
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Live Issue Map'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IssueMapScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              /// 👮 Admin Dashboard
              ElevatedButton.icon(
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Admin Dashboard'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null &&
                      user.email == "richkashyap18@gmail.com") {
                    Navigator.pushNamed(context, '/admin');
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Access Denied"),
                        content: const Text(
                            "You are not authorized to access Admin Dashboard."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
