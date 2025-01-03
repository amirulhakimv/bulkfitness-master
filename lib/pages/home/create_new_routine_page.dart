import 'package:flutter/material.dart';
import '../../components/my_appbar.dart';
import 'exercise_library_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateNewRoutinePage extends StatefulWidget {
  final Map<String, dynamic>? existingRoutine;

  const CreateNewRoutinePage({Key? key, this.existingRoutine}) : super(key: key);

  @override
  _CreateNewRoutinePageState createState() => _CreateNewRoutinePageState();
}

class _CreateNewRoutinePageState extends State<CreateNewRoutinePage> {
  final _routineNameController = TextEditingController();
  List<Map<String, dynamic>> selectedExercises = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (widget.existingRoutine != null) {
      _routineNameController.text = widget.existingRoutine!['title'];
      selectedExercises = List<Map<String, dynamic>>.from(widget.existingRoutine!['exercises']);
    }
  }

  @override
  void dispose() {
    _routineNameController.dispose();
    super.dispose();
  }

  void _navigateToExerciseLibrary() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseLibraryPage(
          onExercisesSelected: (exercises) {
            setState(() {
              selectedExercises = exercises;
            });
          },
          multiSelect: true,
          initialSelectedExercises: selectedExercises,
        ),
      ),
    );
  }

  // Helper method to sanitize exercise data for Firestore
  Map<String, dynamic> _sanitizeExerciseForFirestore(Map<String, dynamic> exercise) {
    return {
      'id': exercise['id'],
      'title': exercise['title'],
    };
  }

  void _saveRoutine() async {
    if (_routineNameController.text.isNotEmpty && selectedExercises.isNotEmpty) {
      try {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          throw Exception('User not logged in');
        }

        // Sanitize the exercises list before saving
        final sanitizedExercises = selectedExercises.map((exercise) =>
            _sanitizeExerciseForFirestore(exercise)
        ).toList();

        final routineData = {
          'title': _routineNameController.text,
          'exercises': sanitizedExercises,
          'isUserCreated': true,
          'isInRoutine': widget.existingRoutine?['isInRoutine'] ?? false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        String docId;
        if (widget.existingRoutine != null) {
          // Update existing routine
          docId = widget.existingRoutine!['id'];
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('workouts')
              .doc(docId)
              .update(routineData);
        } else {
          // Create new routine
          final docRef = await _firestore
              .collection('users')
              .doc(userId)
              .collection('workouts')
              .add(routineData);
          docId = docRef.id;
        }

        routineData['id'] = docId;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Routine saved successfully'),
            duration: Duration(seconds: 1),
          ),
        );

        Navigator.pop(context, routineData);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving routine: $e'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a routine name and add at least one exercise'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _routineNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Split Name',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selected Exercises:',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: selectedExercises.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        selectedExercises[index]['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedExercises.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _navigateToExerciseLibrary,
                    child: const Text('Add Exercises'),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveRoutine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      'Save Routine',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

