import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all challenges
  Stream<List<Map<String, dynamic>>> getChallenges() {
    return _db.collection('challenges').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Add a new challenge (Optional, for admin use)
  Future<void> addChallenge(Map<String, dynamic> challenge) async {
    await _db.collection('challenges').add(challenge);
  }

  // Update join status for a user
  Future<void> toggleJoinStatus(String challengeId, String userId, bool isJoined) async {
    final docRef = _db.collection('challenges').doc(challengeId).collection('participants').doc(userId);
    if (isJoined) {
      await docRef.set({'joinedAt': Timestamp.now()});
    } else {
      await docRef.delete();
    }
  }

}

