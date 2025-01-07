import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/my_appbar.dart';
import '../../components/my_button.dart';

class UserAddExercisePage extends StatefulWidget {
  const UserAddExercisePage({Key? key}) : super(key: key);

  @override
  _UserAddExercisePageState createState() => _UserAddExercisePageState();
}

class _UserAddExercisePageState extends State<UserAddExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedMuscleGroup;

  final List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to add an exercise')),
          );
          return;
        }

        DocumentReference docRef = FirebaseFirestore.instance.collection('user_exercises').doc();

        Map<String, dynamic> exerciseData = {
          'id': docRef.id,
          'title': _titleController.text.trim(),
          'muscleGroup': _selectedMuscleGroup,
          'iconName': 'fitness_center', // Changed from 'icon' to 'iconName'
          'sets': [
            {'set': 1, 'weight': 0, 'reps': '0', 'multiplier': 'x'}
          ],
          'createdAt': FieldValue.serverTimestamp(),
          'userId': user.uid,
        };

        await docRef.set(exerciseData);

        // Modify the data before returning to include the IconData
        Map<String, dynamic> returnData = {
          ...exerciseData,
          'icon': Icons.fitness_center, // Add the actual IconData for the UI
        };

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise added successfully')),
        );

        Navigator.pop(context, returnData);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding exercise: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Custom Exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Exercise Title',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an exercise title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedMuscleGroup,
                  decoration: InputDecoration(
                    labelText: 'Muscle Group',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  items: muscleGroups.map((String group) {
                    return DropdownMenuItem<String>(
                      value: group,
                      child: Text(group),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMuscleGroup = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a muscle group';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: MyButton(
                    onTap: _addExercise,
                    text: 'Add Exercise',
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

