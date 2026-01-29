import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLiveDashboard extends StatelessWidget {
  const AdminLiveDashboard({super.key});

  Future<void> updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('issues')
        .doc(docId)
        .update({'status': newStatus});
  }

  String calculateBadge(int points) {
    if (points >= 300) return "City Guardian 🛡";
    if (points >= 150) return "Civic Hero 🦸";
    if (points >= 50) return "Active Reporter 🏃";
    return "New Citizen 🌱";
  }

  Future<void> rewardUser(String userId, int points) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    final snapshot = await userRef.get();
    final currentPoints = snapshot.data()?['points'] ?? 0;
    final newPoints = currentPoints + points;

    await userRef.update({
      'points': FieldValue.increment(points),
      'badge': calculateBadge(newPoints),
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Resolved":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛡️ Admin Live Control Panel"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No issues reported yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              String status = data['status'] ?? 'Pending';
              const allowed = ['Pending', 'In Progress', 'Resolved'];
              if (!allowed.contains(status)) status = 'Pending';

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'Unknown Issue',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text("📍 ${data['location'] ?? 'N/A'}"),
                      Text("🏢 Dept: ${data['department'] ?? 'N/A'}"),
                      Text("⚡ Urgency: ${data['urgency'] ?? 'N/A'}"),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(status,
                                style:
                                    const TextStyle(color: Colors.white)),
                            backgroundColor: getStatusColor(status),
                          ),
                          DropdownButton<String>(
                            value: status,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Pending',
                                  child: Text('Pending')),
                              DropdownMenuItem(
                                  value: 'In Progress',
                                  child: Text('In Progress')),
                              DropdownMenuItem(
                                  value: 'Resolved',
                                  child: Text('Resolved')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                updateStatus(doc.id, value);
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      if (data.containsKey('userId'))
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.stars),
                            label: const Text("+20 Reward"),
                            onPressed: () {
                              rewardUser(data['userId'], 20);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "🎉 Citizen rewarded +20 points")),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
