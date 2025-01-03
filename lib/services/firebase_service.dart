import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getChallenges() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('challenges').get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching challenges: $e');
      return [];
    }
  }

  Future<void> updateChallengeStatus(String userId, String challengeId, bool isJoined) async {
    try {
      await _firestore.collection('user_challenges').doc('$userId-$challengeId').set({
        'userId': userId,
        'challengeId': challengeId,
        'isJoined': isJoined,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating challenge status: $e');
    }
  }

  Future<bool> getChallengeStatus(String userId, String challengeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('user_challenges')
          .doc('$userId-$challengeId')
          .get();
      return doc.exists ? (doc.data() as Map<String, dynamic>)['isJoined'] ?? false : false;
    } catch (e) {
      print('Error getting challenge status: $e');
      return false;
    }
  }
}

