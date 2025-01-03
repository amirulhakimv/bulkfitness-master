import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final String detailedDescription;
  final String goal;
  final String badge;
  final String overview;
  final List<String> rules;
  final bool isJoined;
  final double progress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.detailedDescription,
    required this.goal,
    required this.badge,
    required this.overview,
    required this.rules,
    this.isJoined = false,
    this.progress = 0.0,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      detailedDescription: data['detailedDescription'] ?? '',
      goal: data['goal'] ?? '',
      badge: data['badge'] ?? '',
      overview: data['overview'] ?? '',
      rules: List<String>.from(data['rules'] ?? []),
      isJoined: data['isJoined'] ?? false,
      progress: (data['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'detailedDescription': detailedDescription,
      'goal': goal,
      'badge': badge,
      'overview': overview,
      'rules': rules,
      'isJoined': isJoined,
      'progress': progress,
    };
  }
}

