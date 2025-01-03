import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/my_appbar.dart';
import '../../components/my_button.dart';
import '../../components/my_text_field.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({Key? key}) : super(key: key);

  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
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
        // Create a new document reference
        DocumentReference docRef = FirebaseFirestore.instance.collection('exercises').doc();

        // Prepare the exercise data
        Map<String, dynamic> exerciseData = {
          'id': docRef.id, // Use the document ID as the exercise ID
          'title': _titleController.text.trim(),
          'muscleGroup': _selectedMuscleGroup,
          'icon': 'fitness_center', // Default icon name
          'sets': [
            {'set': 1, 'weight': 0, 'reps': '0', 'multiplier': 'x'}
          ],
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Set the data for the new document
        await docRef.set(exerciseData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise added successfully')),
        );

        _titleController.clear();
        setState(() {
          _selectedMuscleGroup = null;
        });
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
                  'Add New Exercise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _titleController,
                  hintText: 'Exercise Title',
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an exercise title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedMuscleGroup,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  hint: const Text('Select Muscle Group', style: TextStyle(color: Colors.grey)),
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
                const SizedBox(height: 20),
                MyButton(
                  onTap: _addExercise,
                  text: 'Add Exercise',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

