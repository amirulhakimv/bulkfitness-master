import 'package:bulkfitness/pages/home/custom_work_out_screen.dart';
import 'package:flutter/material.dart';
import 'package:bulkfitness/components/my_appbar.dart';
import 'create_new_routine_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutSplitPage extends StatefulWidget {
  const WorkoutSplitPage({Key? key}) : super(key: key);

  @override
  _WorkoutSplitPageState createState() => _WorkoutSplitPageState();
}

class _WorkoutSplitPageState extends State<WorkoutSplitPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, bool> expandedState = {
    'PPL': false,
    'Bro Split': false,
    'Upper / Lower': false,
  };

  List<Map<String, dynamic>> allSplits = [];
  List<Map<String, dynamic>> myRoutine = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _routinesRef = FirebaseFirestore.instance.collection('routines');

  Map<String, dynamic>? selectedSplitForSwap;


  final Map<String, List<Map<String, dynamic>>> workoutData = {
    'PPL': [
      {
        'title': 'Push Day 1',
        'exercises': [
          {'title': 'Bench Press', 'id': '1'},
          {'title': 'Shoulder Press', 'id': '2'},
          {'title': 'Pec Fly', 'id': '5'},
          {'title': 'Lateral Raise', 'id': '6'},
          {'title': 'Tricep Pushdown', 'id': '7'}
        ],
      },
      {
        'title': 'Pull Day 1',
        'exercises': [
          {'title': 'Deadlift', 'id': '4'},
          {'title': 'Lat Pulldown', 'id': '20'},
          {'title': 'Seated Cable Row', 'id': '8'},
          {'title': 'Dumbbell Bicep Curl', 'id': '3'}
        ],
      },
      {
        'title': 'Leg Day 1',
        'exercises': [
          {'title': 'Squat', 'id': '9'},
          {'title': 'Bulgarian Split Squat', 'id': '10'},
          {'title': 'Seated Leg Curl', 'id': '11'},
          {'title': 'Leg Extension', 'id': '12'},
          {'title': 'Calf Raises', 'id': '13'}
        ],
      },
    ],
    'Bro Split': [
      {
        'title': 'Chest Day',
        'exercises': [
          {'title': 'Bench Press', 'id': '1'},
          {'title': 'Incline Dumbbell Press', 'id': '14'},
          {'title': 'Cable Flyes', 'id': '15'},
          {'title': 'Pushups', 'id': '16'}
        ],
      },
      {
        'title': 'Back Day',
        'exercises': [
          {'title': 'Deadlifts', 'id': '4'},
          {'title': 'Pull-ups', 'id': '18'},
          {'title': 'Bent Over Rows', 'id': '19'},
          {'title': 'Lat Pulldowns', 'id': '20'}
        ],
      },
      {
        'title': 'Leg Day',
        'exercises': [
          {'title': 'Squats', 'id': '9'},
          {'title': 'Leg Press', 'id': '21'},
          {'title': 'Romanian Deadlifts', 'id': '22'},
          {'title': 'Leg Extensions', 'id': '12'},
          {'title': 'Calf Raises', 'id': '13'}
        ],
      },
      {
        'title': 'Shoulder Day',
        'exercises': [
          {'title': 'Military Press', 'id': '23'},
          {'title': 'Lateral Raises', 'id': '6'},
          {'title': 'Front Raises', 'id': '24'},
          {'title': 'Face Pulls', 'id': '25'}
        ],
      },
      {
        'title': 'Arm Day',
        'exercises': [
          {'title': 'Barbell Curls', 'id': '26'},
          {'title': 'Tricep Pushdowns', 'id': '7'},
          {'title': 'Hammer Curls', 'id': '27'},
          {'title': 'Skull Crushers', 'id': '28'}
        ],
      },
    ],
    'Upper / Lower': [
      {
        'title': 'Upper Day 1',
        'exercises': [
          {'title': 'Bench Press', 'id': '1'},
          {'title': 'Rows', 'id': '29'},
          {'title': 'Overhead Press', 'id': '30'},
          {'title': 'Lat Pulldowns', 'id': '20'},
          {'title': 'Dumbbell Bicep Curl', 'id': '3'},
          {'title': 'Tricep Pushdown', 'id': '7'}
        ],
      },
      {
        'title': 'Lower Day 1',
        'exercises': [
          {'title': 'Squats', 'id': '9'},
          {'title': 'Romanian Deadlifts', 'id': '22'},
          {'title': 'Leg Press', 'id': '21'},
          {'title': 'Leg Curls', 'id': '11'},
          {'title': 'Calf Raises', 'id': '13'}
        ],
      },
      {
        'title': 'Upper Day 2',
        'exercises': [
          {'title': 'Incline Press', 'id': '31'},
          {'title': 'Pull-ups', 'id': '18'},
          {'title': 'Lateral Raises', 'id': '6'},
          {'title': 'Face Pulls', 'id': '25'},
          {'title': 'Hammer Curls', 'id': '27'},
          {'title': 'Tricep Pushdowns', 'id': '7'}
        ],
      },
      {
        'title': 'Lower Day 2',
        'exercises': [
          {'title': 'Deadlifts', 'id': '4'},
          {'title': 'Front Squats', 'id': '32'},
          {'title': 'Lunges', 'id': '33'},
          {'title': 'Leg Extensions', 'id': '12'},
          {'title': 'Hip Thrusts', 'id': '34'}
        ],
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWorkouts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadWorkouts() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _firestore.collection('users').doc(userId).collection('workouts').snapshots().listen((snapshot) {
        setState(() {
          allSplits = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          myRoutine = allSplits.where((workout) => workout['isInRoutine'] == true).toList();
          _sortMyRoutine();
        });
      });
    }
  }

  void _sortMyRoutine() {
    myRoutine.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout, int index, bool isRoutine) {
    final uniqueKey = ValueKey('${workout['id']}_${isRoutine ? 'routine' : 'split'}_$index');

    return Dismissible(
      key: uniqueKey,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        if (isRoutine) {
          setState(() {
            workout['isInRoutine'] = false;
            myRoutine.removeAt(index);
          });

          if (workout['routineId'] != null) {
            await _routinesRef.doc(workout['routineId']).delete();
          }

          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('workouts')
              .doc(workout['id'])
              .update({
            'isInRoutine': false,
            'order': null,
            'routineId': null,
          });

          // Update the order of remaining splits
          for (int i = 0; i < myRoutine.length; i++) {
            final split = myRoutine[i];
            if (split['order'] != i) {
              split['order'] = i;
              await _updateSplitOrder(split);
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${workout['title']} removed from routine'),
              duration: Duration(seconds: 1),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  final routineData = {
                    'userId': _auth.currentUser!.uid,
                    'workoutId': workout['id'],
                    'title': workout['title'],
                    'exercises': workout['exercises'],
                    'order': index,
                    'isInRoutine': true,
                  };

                  final docRef = await _routinesRef.add(routineData);

                  setState(() {
                    workout['isInRoutine'] = true;
                    workout['order'] = index;
                    workout['routineId'] = docRef.id;
                    myRoutine.insert(index, workout);
                  });

                  await _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .collection('workouts')
                      .doc(workout['id'])
                      .update({
                    'isInRoutine': true,
                    'order': index,
                    'routineId': docRef.id,
                  });
                },
                textColor: Colors.white,
              ),
            ),
          );
        } else {
          setState(() {
            allSplits.removeAt(index);
          });

          if (workout['routineId'] != null) {
            await _routinesRef.doc(workout['routineId']).delete();
          }

          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .collection('workouts')
              .doc(workout['id'])
              .delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${workout['title']} deleted from splits'),
              duration: Duration(seconds: 1),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  setState(() {
                    allSplits.insert(index, workout);
                  });
                  await _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .collection('workouts')
                      .doc(workout['id'])
                      .set(workout);
                },
                textColor: Colors.white,
              ),
            ),
          );
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: _buildWorkoutCardContent(workout, isRoutine),
    );
  }

  Widget _buildWorkoutCardContent(Map<String, dynamic> workout, bool isRoutine) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: MediaQuery.of(context).size.width * 0.7, // Same width for both routine and splits
        constraints: BoxConstraints(
          minHeight: 80, // Same height for both routine and splits
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isRoutine)
                    IconButton(
                      icon: Icon(
                        Icons.swap_horiz,
                        color: selectedSplitForSwap == workout ? Colors.blue : Colors.grey[600],
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => _handleSwapButton(workout),
                    ),
                ],
              ),
              if (!isRoutine || workout['exercises'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  workout['exercises'] is List
                      ? (workout['exercises'] as List).map((e) => e['title']).join(', ')
                      : workout['exercises'].toString(),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _editRoutine(workout),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                      if (!isRoutine && !myRoutine.any((routine) => routine['id'] == workout['id']))
                        TextButton(
                          onPressed: () => _addToRoutine(workout),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Add to Routine',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () => _startWorkout(workout),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
    );
  }

  void _handleSwapButton(Map<String, dynamic> workout) {
    if (selectedSplitForSwap == null) {
      setState(() {
        selectedSplitForSwap = workout;
      });
    } else if (selectedSplitForSwap == workout) {
      setState(() {
        selectedSplitForSwap = null;
      });
    } else {
      _swapSplits(selectedSplitForSwap!, workout);
    }
  }

  void _swapSplits(Map<String, dynamic> split1, Map<String, dynamic> split2) async {
    int index1 = myRoutine.indexWhere((split) => split['id'] == split1['id']);
    int index2 = myRoutine.indexWhere((split) => split['id'] == split2['id']);

    if (index1 != -1 && index2 != -1) {
      // Store original orders
      final order1 = split1['order'];
      final order2 = split2['order'];

      // Update the orders
      split1['order'] = order2;
      split2['order'] = order1;

      // Update state
      setState(() {
        myRoutine[index1] = split2;
        myRoutine[index2] = split1;
        selectedSplitForSwap = null;
      });

      // Update both splits in Firestore workouts collection
      await Future.wait([
        _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('workouts')
            .doc(split1['id'])
            .update({'order': split1['order']}),
        _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('workouts')
            .doc(split2['id'])
            .update({'order': split2['order']}),
      ]);

      // Update both splits in routines collection if they exist
      if (split1['routineId'] != null) {
        await _routinesRef.doc(split1['routineId']).update({'order': split1['order']});
      }
      if (split2['routineId'] != null) {
        await _routinesRef.doc(split2['routineId']).update({'order': split2['order']});
      }

      // Sort the routine after swap
      _sortMyRoutine();
    }
  }

  Future<void> _updateSplitOrder(Map<String, dynamic> split) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('workouts')
        .doc(split['id'])
        .update({'order': split['order']});

    if (split['routineId'] != null) {
      await _routinesRef.doc(split['routineId']).update({'order': split['order']});
    }
  }

  void _editRoutine(Map<String, dynamic> routine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewRoutinePage(
          existingRoutine: {
            ...routine,
            'exercises': routine['exercises'] is String
                ? [] // Convert empty string to empty array
                : routine['exercises'],
          },
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      result['isInRoutine'] = routine['isInRoutine'];

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('workouts')
          .doc(routine['id'])
          .update(result);

      if (result['isInRoutine'] && routine['routineId'] != null) {
        await _routinesRef.doc(routine['routineId']).update({
          'title': result['title'],
          'exercises': result['exercises'],
        });
      }

      setState(() {
        int splitIndex = allSplits.indexWhere((split) => split['id'] == routine['id']);
        if (splitIndex != -1) {
          allSplits[splitIndex] = {...allSplits[splitIndex], ...result};
        }

        if (result['isInRoutine']) {
          int routineIndex = myRoutine.indexWhere((r) => r['id'] == routine['id']);
          if (routineIndex != -1) {
            myRoutine[routineIndex] = {...myRoutine[routineIndex], ...result};
          } else {
            myRoutine.add({...result, 'id': routine['id']});
          }
        }
        _sortMyRoutine();
      });
    }
  }

  void _addToRoutine(Map<String, dynamic> workout) async {
    if (!myRoutine.any((routine) => routine['id'] == workout['id'])) {
      final newOrder = myRoutine.isEmpty ? 0 : myRoutine.map((r) => r['order'] ?? 0).reduce((a, b) => a > b ? a : b) + 1;

      final routineData = {
        'userId': _auth.currentUser!.uid,
        'workoutId': workout['id'],
        'title': workout['title'],
        'exercises': workout['exercises'],
        'order': newOrder,
        'isInRoutine': true,
      };

      final docRef = await _routinesRef.add(routineData);

      setState(() {
        workout['isInRoutine'] = true;
        workout['order'] = newOrder;
        myRoutine.add(workout);
        // Force a rebuild of the widget
        allSplits = List.from(allSplits);
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('workouts')
          .doc(workout['id'])
          .update({
        'isInRoutine': true,
        'order': newOrder,
        'routineId': docRef.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${workout['title']} added to My Routine'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _addSplitFromSearch(Map<String, dynamic> workout) async {
    bool isInAllSplits = allSplits.any((split) =>
    split['title'] == workout['title'] &&
        split['exercises'].toString() == workout['exercises'].toString());

    if (!isInAllSplits) {
      final newWorkout = Map<String, dynamic>.from(workout);
      newWorkout['isUserCreated'] = false;
      newWorkout['isInRoutine'] = false;
      newWorkout['id'] = DateTime.now().millisecondsSinceEpoch.toString();

      setState(() {
        allSplits.add(newWorkout);
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('workouts')
          .doc(newWorkout['id'])
          .set(newWorkout);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newWorkout['title']} added to My Splits'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${workout['title']} is already in My Splits'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _startWorkout(Map<String, dynamic> workout) {
    List<Map<String, dynamic>> exercises = (workout['exercises'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWorkOutScreen(
          initialExercises: exercises,
        ),
      ),
    );
  }

  Widget _buildMySplitTab() {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 6,
      radius: Radius.circular(10),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'My Routine',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...myRoutine.asMap().entries.map((entry) => _buildWorkoutCard(entry.value, entry.key, true)),
            if (myRoutine.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No routines added yet. Add splits to your routine from the My Splits section.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'My Splits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...allSplits.asMap().entries.map((entry) => _buildWorkoutCard(entry.value, entry.key, false)),
            if (allSplits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No splits added yet.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateNewRoutinePage()),
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      print('Received new routine: $result');
                      setState(() {
                        allSplits.add(result);
                      });
                      print('Updated allSplits: $allSplits');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create New Split',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 6,
      radius: Radius.circular(10),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Pick Your Split',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Don\'t know what to do for the day?\nTake a look at these routines created by other users',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...workoutData.entries.map((entry) => _buildExpandableWorkout(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableWorkout(String title, List<Map<String, dynamic>> workouts) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              expandedState[title] = !(expandedState[title] ?? false);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  expandedState[title] ?? false
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (expandedState[title] ?? false)
          Column(
            children: workouts.map((workout) => _buildWorkoutItem(workout)).toList(),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildWorkoutItem(Map<String, dynamic> workout) {
    bool isAdded = allSplits.any((split) =>
    split['title'] == workout['title'] &&
        split['exercises'].toString() == workout['exercises'].toString());

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout['title'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workout['exercises'] is List
                      ? (workout['exercises'] as List).map((e) => e['title']).join(', ')
                      : workout['exercises'].toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isAdded ? Colors.green : Colors.white, width: 1),
            ),
            child: IconButton(
              icon: Icon(
                isAdded ? Icons.check : Icons.add,
                color: isAdded ? Colors.green : Colors.white,
              ),
              onPressed: isAdded ? null : () => _addSplitFromSearch(workout),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: MyAppbar(
        showBackButton: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'My Splits'),
              Tab(text: 'Search'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMySplitTab(),
                _buildSearchTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

