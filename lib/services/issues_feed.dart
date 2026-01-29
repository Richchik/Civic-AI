import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/emergency_screen.dart';
import 'screens/user_points_card.dart';
import 'screens/leaderboard_screen.dart';

class IssuesFeed extends StatelessWidget {
  const IssuesFeed({super.key});

  String getRemainingTime(Timestamp expectedResolutionAt) {
    final diff =
        expectedResolutionAt.toDate().difference(DateTime.now());
    if (diff.isNegative) return "Overdue";

    final days = diff.inHours ~/ 24;
    final hours = diff.inHours % 24;

    return days > 0 ? "$days day(s) $hours hour(s)" : "$hours hour(s)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Civic Issues'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const LeaderboardScreen()),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.sos),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const EmergencyScreen()),
          );
        },
      ),

      body: Column(
        children: [
          const UserPointsCard(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('issues')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                      child: Text('No issues reported yet'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;

                    final Timestamp? eta =
                        data['expectedResolutionAt'];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.report,
                            color: Colors.red),
                        title: Text(data['title'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(data['description'] ?? ''),
                            Text("📍 ${data['location'] ?? ''}"),

                            if ((data['building'] ?? '').isNotEmpty)
                              Text("🏢 ${data['building']}"),

                            if ((data['room'] ?? '').isNotEmpty)
                              Text("🚪 ${data['room']}"),

                            if ((data['landmark'] ?? '').isNotEmpty)
                              Text("📍 Landmark: ${data['landmark']}"),

                            if (eta != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer,
                                        size: 16,
                                        color: Colors.orange),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Expected in ${getRemainingTime(eta)}",
                                      style: const TextStyle(
                                          color: Colors.orange),
                                    ),
                                  ],
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
          ),
        ],
      ),
    );
  }
}

