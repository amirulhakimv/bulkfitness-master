import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/my_appbar.dart';

class ChallengeDetailsPage extends StatelessWidget {
  final String challengeId;

  ChallengeDetailsPage({Key? key, required this.challengeId}) : super(key: key);

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(
        showBackButton: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('challenges').doc(challengeId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Challenge not found.', style: TextStyle(color: Colors.white)));
          }

          var challengeData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challengeData['title'] ?? 'Untitled Challenge',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  challengeData['description'] ?? 'No description',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Text(
                  'Exercise: ${challengeData['exerciseTitle'] ?? 'Not specified'}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Text(
                  'Target: ${challengeData['timesPerWeek'] ?? 0} times per week',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                if (challengeData['weight'] != null)
                  Text(
                    'Weight Goal: ${challengeData['weight']} kg',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                const SizedBox(height: 24),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user_challenges')
                      .doc('${userId}_${challengeId}')
                      .snapshots(),
                  builder: (context, userChallengeSnapshot) {
                    if (userChallengeSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    bool hasJoined = userChallengeSnapshot.hasData && userChallengeSnapshot.data!.exists;

                    if (!hasJoined) {
                      return ElevatedButton(
                        onPressed: () => _joinChallenge(challengeData),
                        child: Text('Join Challenge'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      );
                    }

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getUserProgress(challengeData),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        Map<String, dynamic> progress = snapshot.data ?? {'current': 0, 'target': 0};
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress: ${progress['current']} / ${progress['target']}',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress['current'] / progress['target'],
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _joinChallenge(Map<String, dynamic> challengeData) async {
    await FirebaseFirestore.instance
        .collection('user_challenges')
        .doc('${userId}_$challengeId')
        .set({
      'userId': userId,
      'challengeId': challengeId,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> _getUserProgress(Map<String, dynamic> challengeData) async {
    QuerySnapshot completedWorkouts = await FirebaseFirestore.instance
        .collection('completed_workouts')
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .get();

    int timesCompleted = completedWorkouts.docs.length;
    int targetTimes = challengeData['timesPerWeek'] * 7; // Assuming the challenge is for 7 weeks

    if (challengeData['weight'] != null) {
      // If it's a weight-based challenge, find the maximum weight lifted
      double maxWeight = 0;
      for (var doc in completedWorkouts.docs) {
        double weight = doc['weight'] ?? 0;
        if (weight > maxWeight) maxWeight = weight;
      }
      return {
        'current': maxWeight,
        'target': challengeData['weight'],
      };
    } else {
      // If it's a frequency-based challenge
      return {
        'current': timesCompleted,
        'target': targetTimes,
      };
    }
  }
}

