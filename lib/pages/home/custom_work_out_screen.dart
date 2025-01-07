import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:bulkfitness/components/my_add_discard.dart';
import 'package:bulkfitness/components/my_appbar.dart';
import 'package:bulkfitness/components/my_timer.dart';
import 'package:bulkfitness/pages/home/exercise_library_page.dart';
import 'package:bulkfitness/components/my_add_set_temp.dart';
import 'package:bulkfitness/pages/first_page.dart';

class CustomWorkOutScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialExercises;
  final bool isFromTodaysWorkout;  // Add this parameter
  final String? challengeId;

  const CustomWorkOutScreen({
    Key? key,
    this.initialExercises,
    this.isFromTodaysWorkout = false,  // Default to false
    this.challengeId,  // Add this line
  }) : super(key: key);

  @override
  _CustomWorkOutScreenState createState() => _CustomWorkOutScreenState();
}

class _CustomWorkOutScreenState extends State<CustomWorkOutScreen> {
  final CollectionReference _workoutsRef = FirebaseFirestore.instance.collection("custom_workout");
  final CollectionReference _completedWorkoutsRef = FirebaseFirestore.instance.collection("completed_workouts");
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  late final GlobalTimer _globalTimer;

  bool isRestTimerRunning = false;
  List<Map<String, dynamic>> exercises = [];
  StreamSubscription<QuerySnapshot>? _workoutsSubscription;

  @override
  void initState() {
    super.initState();
    _globalTimer = GlobalTimer.getInstance(currentUserId);
    _setupWorkoutsListener();

    if (widget.initialExercises != null && widget.initialExercises!.isNotEmpty) {
      _workoutsRef
          .where('userId', isEqualTo: currentUserId)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isEmpty) {
          _addInitialExercises();
        }
      });
    }
  }

  Future<void> _addInitialExercises() async {
    for (var exercise in widget.initialExercises!) {
      final newExercise = {
        'title': exercise['title'],
        'id': exercise['id'],
        'icon': Icons.fitness_center,
        'sets': [
          {
            'set': 1,
            'weight': 0,
            'reps': 0,
            'isCompleted': false,
          }
        ],
      };
      await _addWorkout(newExercise);
    }
  }

  @override
  void dispose() {
    _workoutsSubscription?.cancel();
    super.dispose();
  }

  void _setupWorkoutsListener() {
    if (currentUserId.isEmpty) return;
    _workoutsSubscription = _workoutsRef
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .listen(_handleWorkoutsSnapshot);
  }

  void _handleWorkoutsSnapshot(QuerySnapshot snapshot) {
    List<Map<String, dynamic>> updatedExercises = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "id": doc.id,
        "title": data['title'],
        "icon": Icons.fitness_center,
        "sets": (data['sets'] as List<dynamic>).map((set) => {
          "set": set['set'],
          "weight": set['weight'],
          "reps": set['reps'],
          "isCompleted": set['isCompleted'] ?? false,
        }).toList(),
      };
    }).toList();

    setState(() {
      exercises = updatedExercises;
    });
  }

  Future<void> _addWorkout(Map<String, dynamic> exercise) async {
    if (currentUserId.isEmpty) return;
    final newWorkout = {
      'title': exercise['title'],
      'sets': exercise['sets'],
      'userId': currentUserId,
    };

    try {
      await _workoutsRef.add(newWorkout);
    } catch (e) {
      print('Error adding workout: $e');
    }
  }

  Future<void> _updateWorkout(String id, Map<String, dynamic> exercise) async {
    if (currentUserId.isEmpty) return;
    final updatedWorkout = {
      'title': exercise['title'],
      'sets': exercise['sets'].map((set) => {
        'set': set['set'],
        'weight': double.parse(set['weight'].toString()),
        'reps': set['reps'],
        'isCompleted': set['isCompleted'] ?? false,
      }).toList(),
    };

    try {
      await _workoutsRef.doc(id).update(updatedWorkout);
    } catch (e) {
      print('Error updating workout: $e');
    }
  }

  Future<void> _deleteWorkout(String id) async {
    try {
      await _workoutsRef.doc(id).delete();
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }

  Future<void> _deleteSet(String exerciseId, int setIndex) async {
    if (currentUserId.isEmpty) return;

    try {
      final exerciseDoc = await _workoutsRef.doc(exerciseId).get();
      if (exerciseDoc.exists) {
        final exerciseData = exerciseDoc.data() as Map<String, dynamic>;
        final sets = List<Map<String, dynamic>>.from(exerciseData['sets']);

        if (setIndex >= 0 && setIndex < sets.length) {
          sets.removeAt(setIndex);

          for (int i = 0; i < sets.length; i++) {
            sets[i]['set'] = i + 1;
          }

          await _workoutsRef.doc(exerciseId).update({'sets': sets});
        }
      }
    } catch (e) {
      print('Error deleting set: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete set. Please try again.'),
          duration: Duration(seconds: 1),),
      );
    }
  }

  void _showExerciseOptions(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.arrow_back, color: Colors.white),
                title: Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Divider(color: Colors.grey[800]),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: ListTile(
                  leading: Icon(Icons.swap_horiz, color: Colors.blue),
                  title: Text(
                    'Swap Exercise',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _swapExercise(exercise);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete Exercise',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onTap: () {
                    _deleteWorkout(exercise['id']);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _swapExercise(Map<String, dynamic> oldExercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseLibraryPage(
          onExercisesSelected: (selectedExercises) {
            if (selectedExercises.isNotEmpty) {
              Map<String, dynamic> newExercise = Map<String, dynamic>.from(selectedExercises.first);
              newExercise['sets'] = oldExercise['sets'];
              _updateWorkout(oldExercise['id'], newExercise);
            }
          },
          multiSelect: false,
          initialSelectedExercises: exercises,
          exerciseToSwap: oldExercise,
        ),
      ),
    );
  }

  void _showDiscardConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Discard Workout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            'Are you sure you want to discard your workout? This action cannot be undone.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Discard',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _discardWorkout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _discardWorkout() async {
    if (currentUserId.isEmpty) return;

    try {
      _globalTimer.resetTimer();

      QuerySnapshot snapshot = await _workoutsRef.where('userId', isEqualTo: currentUserId).get();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      setState(() {
        exercises = [];
        isRestTimerRunning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workout discarded successfully'),
          duration: Duration(seconds: 1),),
      );

      // Only pop with result if coming from today's workout
      if (widget.isFromTodaysWorkout) {
        Navigator.of(context).pop('discarded');
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FirstPage()),
        );
      }
    } catch (e) {
      print('Error discarding workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to discard workout. Please try again.'),
          duration: Duration(seconds: 1),),
      );
    }
  }

  void _finishWorkout() {
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot finish workout. No exercises added.'),
          duration: Duration(seconds: 1),),
      );
      return;
    }

    _globalTimer.stopTimer();
    int workoutDuration = _globalTimer.getCurrentTime();

    _saveWorkoutData(workoutDuration);

    _globalTimer.resetTimer();

    print('Workout finished. Duration: $workoutDuration seconds');

    if (widget.challengeId != null) {
      _completeChallenge(widget.challengeId!);
    }

    Navigator.of(context).pop('completed');
  }

  Future<void> _saveWorkoutData(int duration) async {
    if (currentUserId.isEmpty) return;

    try {
      Map<String, dynamic> workoutData = {
        'userId': currentUserId,
        'date': DateTime.now(),
        'duration': duration,
        'exercises': exercises.map((exercise) {
          return {
            'title': exercise['title'],
            'sets': exercise['sets'],
          };
        }).toList(),
      };

      // Use a transaction to ensure atomic updates
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Add completed workout
        DocumentReference newWorkoutRef = _completedWorkoutsRef.doc();
        transaction.set(newWorkoutRef, workoutData);

        // Clear current workout
        QuerySnapshot snapshot = await _workoutsRef
            .where('userId', isEqualTo: currentUserId)
            .get();

        for (var doc in snapshot.docs) {
          transaction.delete(doc.reference);
        }
      });

      setState(() {
        exercises = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workout saved successfully'),
          duration: Duration(seconds: 1),),
      );
    } catch (e) {
      print('Error saving workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save workout. Please try again.'),
          duration: Duration(seconds: 1),),
      );
    }
  }

  void _startRestTimer() {
    const int restTime = 60;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Rest Timer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTimer(
                initialSeconds: restTime,
                isWorkoutTimer: false,
                onComplete: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isRestTimerRunning = false;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isRestTimerRunning = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeChallenge(String challengeId) async {
    if (currentUserId.isEmpty) return;

    try {
      // Get a reference to the user's document and challenge document
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final challengeRef = FirebaseFirestore.instance.collection('challenges').doc(challengeId);

      // Use a transaction to ensure data consistency
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the current user document and challenge document
        DocumentSnapshot userDoc = await transaction.get(userRef);
        DocumentSnapshot challengeDoc = await transaction.get(challengeRef);

        if (!challengeDoc.exists) {
          throw Exception('Challenge not found');
        }

        // Get challenge data
        final challengeData = challengeDoc.data() as Map<String, dynamic>;
        final String badgeId = challengeData['badgeId'] ?? 'default_badge_${challengeId}';
        final String badgeName = challengeData['badgeName'] ?? 'Challenge Badge';

        // If the user document doesn't exist, create it
        if (!userDoc.exists) {
          transaction.set(userRef, {
            'completedChallenges': [],
            'badges': [],
          });
        }

        // Get the current arrays or create empty ones if they don't exist
        List<String> completedChallenges = [];
        List<Map<String, dynamic>> badges = [];

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          completedChallenges = List<String>.from(userData['completedChallenges'] ?? []);
          badges = List<Map<String, dynamic>>.from(userData['badges'] ?? []);
        }

        // Add the new challenge and badge if they don't already exist
        if (!completedChallenges.contains(challengeId)) {
          completedChallenges.add(challengeId);
        }

        // Check if badge already exists
        bool badgeExists = badges.any((badge) => badge['id'] == badgeId);

        if (!badgeExists) {
          badges.add({
            'id': badgeId,
            'name': badgeName,
            'earnedAt': DateTime.now().toIso8601String(),
            'challengeId': challengeId,
          });
        }

        // Update the user document with the new arrays
        transaction.update(userRef, {
          'completedChallenges': completedChallenges,
          'badges': badges,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge completed! You earned a new badge!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error completing challenge: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete challenge. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  Future<bool> _onWillPop() async {
    if (exercises.isNotEmpty) {
      if (widget.isFromTodaysWorkout) {
        Navigator.of(context).pop('inProgress');
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: MyAppbar(
          showBackButton: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: MyTimer(
                  initialSeconds: 0,
                  isWorkoutTimer: true,
                  onFinish: _finishWorkout,
                ),
              ),
            ),
            Expanded(
              child: exercises.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Start Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add exercise to start your workout',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return _buildExerciseSection(exercises[index]);
                },
              ),
            ),
            MyAddDiscard(
              onAddExercise: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseLibraryPage(
                      onExercisesSelected: (selectedExercises) {
                        for (var exercise in selectedExercises) {
                          if (!exercises.any((e) => e['title'] == exercise['title'])) {
                            _addWorkout(exercise);
                          }
                        }
                      },
                      multiSelect: true,
                      initialSelectedExercises: exercises,
                    ),
                  ),
                );
              },
              onDiscardWorkout: _showDiscardConfirmation,
              onRestTimerComplete: () {
                setState(() {
                  isRestTimerRunning = false;
                });
              },
              isRestTimerRunning: isRestTimerRunning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection(Map<String, dynamic> exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(exercise['icon'] as IconData, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              exercise['title'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                _showExerciseOptions(exercise);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  SizedBox(width: 60, child: Text('Set', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  Expanded(child: Text('Weight', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)),
                  Expanded(child: Text('Reps', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)),
                  SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...(exercise['sets'] as List<Map<String, dynamic>>).asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> set = entry.value;
              return MyAddSetTemp(
                set: set,
                isHistory: false,
                onComplete: (isCompleted) {
                  setState(() {
                    set['isCompleted'] = isCompleted;
                  });
                  _updateWorkout(exercise['id'], exercise);
                  if (isCompleted) {
                    setState(() {
                      isRestTimerRunning = true;
                    });
                    _startRestTimer();
                  }
                },
                onUpdate: (field, value) {
                  setState(() {
                    if (field == 'weight') {
                      set[field] = double.tryParse(value) ?? 0.0;
                    } else {
                      set[field] = int.tryParse(value) ?? 0;
                    }
                  });
                  _updateWorkout(exercise['id'], exercise);
                },
                onDelete: () => _deleteSet(exercise['id'], index),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    (exercise['sets'] as List<Map<String, dynamic>>).add({
                      'set': (exercise['sets'] as List).length + 1,
                      'weight': 0,
                      'reps': 0,
                      'isCompleted': false,
                    });
                  });
                  _updateWorkout(exercise['id'], exercise);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Add Set'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

