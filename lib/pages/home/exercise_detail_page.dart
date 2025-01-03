import 'package:flutter/material.dart';
import '../../components/my_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final String exerciseId;

  const ExerciseDetailPage({
    Key? key,
    required this.exercise,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<String> howToSteps;
  late Map<String, String> usefulTips;

  final Map<String, Map<String, dynamic>> exerciseInstructions = {
    'Bench Press': {
      'steps': [
        'Lie on the bench with your eyes under the bar',
        'Grip the bar with hands slightly wider than shoulder-width',
        'Unrack the bar and lower it to your mid-chest',
        'Press the bar back up to the starting position',
      ],
      'tips': {
        'Grip': 'Keep your wrists straight and knuckles facing the ceiling',
        'Breathing': 'Inhale as you lower the bar, exhale as you press up',
        'Form': 'Keep your feet flat on the ground and maintain a slight arch in your lower back',
      },
    },
    'Shoulder Press': {
      'steps': [
        'Stand with feet shoulder-width apart',
        'Hold the bar at shoulder level with an overhand grip',
        'Press the bar overhead until your arms are fully extended',
        'Lower the bar back to shoulder level',
      ],
      'tips': {
        'Core': 'Keep your core tight to maintain stability',
        'Elbows': 'Keep your elbows slightly in front of the bar as you press',
        'Head': 'Move your head back slightly as you press to avoid hitting your chin',
      },
    },
    'Dumbbell Bicep Curl': {
      'steps': [
        'Stand with feet shoulder-width apart, holding dumbbells at your sides',
        'Keep your elbows close to your torso',
        'Curl the weights up towards your shoulders',
        'Lower the weights back down to the starting position',
      ],
      'tips': {
        'Control': 'Avoid swinging the weights; use controlled movements',
        'Wrists': 'Keep your wrists straight throughout the movement',
        'Range': 'Fully extend your arms at the bottom of the movement',
      },
    },
    'Deadlift': {
      'steps': [
        'Stand with feet hip-width apart, toes under the bar',
        'Bend at the hips and knees to lower your body, grasp the bar',
        'Lift the bar by extending your hips and knees',
        'Lower the bar back to the ground with a controlled movement',
      ],
      'tips': {
        'Back': 'Keep your back straight throughout the entire movement',
        'Arms': 'Keep your arms straight; they should only hold the weight',
        'Feet': 'Keep your feet flat on the ground throughout the lift',
      },
    },
  };

  Future<List<Map<String, dynamic>>> fetchExerciseHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('completed_workouts')
          .where('userId', isEqualTo: userId)
          .get();

      final documents = querySnapshot.docs;
      documents.sort((a, b) => (b.data()['date'] as Timestamp)
          .compareTo(a.data()['date'] as Timestamp));

      List<Map<String, dynamic>> sessions = [];

      for (var doc in documents) {
        if (sessions.length >= 5) break;

        final data = doc.data();
        final exercises = data['exercises'] as List<dynamic>;

        for (var exercise in exercises) {
          if (exercise['title'] == widget.exercise['title']) {
            final sets = exercise['sets'] as List<dynamic>;
            if (sets.isNotEmpty) {
              sessions.add({
                'day': _formatDate((data['date'] as Timestamp).toDate()),
                'date': _formatDateShort((data['date'] as Timestamp).toDate()),
                'sets': sets.map((set) => {
                  'set': set['set'].toString(),
                  'reps': set['reps'].toString(),
                  'weight': set['weight'].toString(),
                }).toList(),
              });
            }
            break;
          }
        }
      }

      return sessions;
    } catch (e) {
      print('Error fetching exercise history: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeExerciseInstructions();
  }

  void _initializeExerciseInstructions() {
    final exerciseTitle = widget.exercise['title'] as String;
    final instructions = exerciseInstructions[exerciseTitle];

    if (instructions != null) {
      howToSteps = instructions['steps'] as List<String>;
      usefulTips = Map<String, String>.from(instructions['tips'] as Map);
    } else {
      howToSteps = ['Instructions not available for this exercise'];
      usefulTips = {'Note': 'Tips not available for this exercise'};
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Useful Tips',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: usefulTips.entries
              .map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.key,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.value,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Set',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Reps',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'kg',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetItem(Map<String, dynamic> set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              set['set'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              set['reps'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              set['weight'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session['day'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                session['date'],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        _buildHistoryHeader(),
        ...(session['sets'] as List<Map<String, dynamic>>).map(_buildSetItem),
        Divider(
          color: Colors.grey[800],
          height: 32,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(showBackButton: true),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'How to'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Summary Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                widget.exercise['icon'] as IconData,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.exercise['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchExerciseHistory(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('No history available',
                                  style: TextStyle(color: Colors.grey));
                            } else {
                              return Column(
                                children: snapshot.data!
                                    .map((session) => _buildSessionItem(session))
                                    .toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // How to Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...howToSteps.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            '${entry.key + 1}. ${entry.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )).toList(),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: _showTipsDialog,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.help_outline,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Useful Tips',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

