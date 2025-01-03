import 'dart:async';
import 'package:bulkfitness/components/my_appbar.dart';
import 'package:bulkfitness/pages/home/workout_split_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'custom_work_out_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> myRoutine = [];
  Map<String, dynamic>? todaysWorkout;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _completedWorkoutsSubscription;
  bool isWorkoutCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _loadRoutineWorkouts();
    _checkCompletedWorkouts();
  }

  @override
  void dispose() {
    _completedWorkoutsSubscription?.cancel();
    super.dispose();
  }

  void _checkCompletedWorkouts() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      _completedWorkoutsSubscription = _firestore
          .collection('completed_workouts')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            isWorkoutCompletedToday = snapshot.docs.isNotEmpty;
            if (isWorkoutCompletedToday) {
              todaysWorkout = null;
            }
          });
        }
      });
    }
  }

  void _loadRoutineWorkouts() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('isInRoutine', isEqualTo: true)
          .orderBy('order', descending: false)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            myRoutine = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();

            if (!isWorkoutCompletedToday && myRoutine.isNotEmpty) {
              todaysWorkout = myRoutine.firstWhere(
                    (workout) => workout['inProgress'] != true,
                orElse: () => myRoutine.first,
              );
            }
          });
        }
      });
    }
  }

  void _startWorkout(Map<String, dynamic> workout) {
    List<Map<String, dynamic>> exercises = [];
    if (workout['inProgress'] != true) {
      exercises = (workout['exercises'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWorkOutScreen(
          initialExercises: exercises,
          isFromTodaysWorkout: true,
        ),
      ),
    ).then((result) {
      setState(() {
        if (result == 'inProgress') {
          todaysWorkout!['inProgress'] = true;
        } else if (result == 'completed') {
          isWorkoutCompletedToday = true;
          todaysWorkout = null;
        }
      });
    });
  }

  void _startNextWorkout() {
    setState(() {
      if (myRoutine.isNotEmpty) {
        final currentWorkout = myRoutine.removeAt(0);
        currentWorkout['inProgress'] = false;  // Reset the inProgress flag
        myRoutine.add(currentWorkout);
        todaysWorkout = myRoutine.first;
        isWorkoutCompletedToday = false;
        _resetWorkoutProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: MyAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 24, right: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todaysWorkout != null) ...[
                const Text(
                  'Today\'s Workout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 80),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todaysWorkout!['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todaysWorkout!['exercises'] is List
                              ? (todaysWorkout!['exercises'] as List)
                              .map((e) => e['title'])
                              .join(', ')
                              : todaysWorkout!['exercises'].toString(),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: SizedBox()),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () => _startWorkout(todaysWorkout!),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    todaysWorkout!['inProgress'] == true ? 'Continue' : 'Start',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (myRoutine.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Good job for today! Your next session is tomorrow.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _startNextWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Start Next Workout Anyway',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No workout routine set up.\nGo to Workout Split to set up your routine.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Workout Options Section
              Row(
                children: [
                  // Start Custom Workout Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomWorkOutScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 140,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start Custom\nWorkout',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Workout Split Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkoutSplitPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 140,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Workout\nSplit',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // History Section
              const Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Workout History List
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchWorkoutHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No workout history available',
                        style: TextStyle(color: Colors.grey));
                  } else {
                    return Column(
                      children: snapshot.data!
                          .map((workout) => _buildWorkoutHistoryItem(workout))
                          .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchWorkoutHistory() async {
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

        sessions.add({
          'date': (data['date'] as Timestamp).toDate(),
          'duration': data['duration'] as int,
          'exercises': exercises.map((e) => {
            'title': e['title'] as String,
            'sets': (e['sets'] as List<dynamic>).map((set) => {
              'set': set['set'],
              'weight': set['weight'],
              'reps': set['reps'],
            }).toList(),
          }).toList(),
        });
      }

      return sessions;
    } catch (e) {
      print('Error fetching workout history: $e');
      return [];
    }
  }

  Widget _buildWorkoutHistoryItem(Map<String, dynamic> workout) {
    final date = workout['date'] as DateTime;
    final duration = workout['duration'] as int;
    final exercises = workout['exercises'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.grey[900],
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatDate(date)} - ${_formatDateShort(date)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${duration ~/ 60}m ${duration % 60}s',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              exercises.map((e) => e['title'] as String).join(', '),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exercises.map<Widget>((exercise) {
                final sets = exercise['sets'] as List<dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Set',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Weight',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Reps',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...sets.map((set) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              set['set'].toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${set['weight']} kg',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              set['reps'].toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }

  void _resetWorkoutProgress() {
    setState(() {
      if (todaysWorkout != null) {
        todaysWorkout!['inProgress'] = false;
      }
    });
  }
}

