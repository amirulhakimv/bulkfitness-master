import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bulkfitness/components/my_appbar.dart';
import 'package:bulkfitness/pages/home/custom_work_out_screen.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Challenges",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('challenges').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No challenges available.', style: TextStyle(color: Colors.white)));
                }

                // Filter out completed challenges
                return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('users').doc(_auth.currentUser!.uid).snapshots(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Safely get completedChallenges, defaulting to empty list if it doesn't exist
                    List<String> completedChallenges = [];
                    try {
                      final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                      if (userData != null && userData.containsKey('completedChallenges')) {
                        completedChallenges = List<String>.from(userData['completedChallenges']);
                      }
                    } catch (e) {
                      print('Error getting completed challenges: $e');
                    }

                    var availableChallenges = snapshot.data!.docs.where((doc) => !completedChallenges.contains(doc.id)).toList();

                    if (availableChallenges.isEmpty) {
                      return const Center(child: Text('No challenges available.', style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      itemCount: availableChallenges.length,
                      itemBuilder: (context, index) {
                        var challenge = availableChallenges[index];
                        return _buildChallengeCard(challenge);
                      },
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

  Widget _buildChallengeCard(DocumentSnapshot challenge) {
    var challengeData = challenge.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey[900],
      elevation: 5,
      child: InkWell(
        onTap: () => _showChallengeDetails(context, challenge),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challengeData['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                challengeData['description'],
                style: TextStyle(color: Colors.grey[400]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start: ${_formatDate(challengeData['startDate'])}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      Text(
                        'End: ${_formatDate(challengeData['endDate'])}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _joinChallenge(challenge),
                    child: const Text('Join Challenge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChallengeDetails(BuildContext context, DocumentSnapshot challenge) {
    var challengeData = challenge.data() as Map<String, dynamic>;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              challengeData['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              challengeData['description'],
              style: TextStyle(color: Colors.grey[300], fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Add badge information
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.military_tech,
                    color: Colors.amber,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reward Badge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          challengeData['badgeName'] ?? 'Complete this challenge to earn a special badge!',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date: ${_formatDate(challengeData['startDate'])}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      'End Date: ${_formatDate(challengeData['endDate'])}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _joinChallenge(challenge);
                  },
                  child: const Text('Join Challenge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Exercises:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List<Map<String, dynamic>>.from(challengeData['exercises'])
                .map((exercise) => ListTile(
              title: Text(
                exercise['title'],
                style: const TextStyle(color: Colors.white),
              ),
              leading: Icon(Icons.fitness_center, color: Colors.blue),
            ))
                .toList(),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  void _joinChallenge(DocumentSnapshot challenge) {
    var challengeData = challenge.data() as Map<String, dynamic>;
    List<Map<String, dynamic>> exercises = List<Map<String, dynamic>>.from(challengeData['exercises']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWorkOutScreen(
          initialExercises: exercises,
          isFromTodaysWorkout: false,
          challengeId: challenge.id,
        ),
      ),
    );
  }
}

