import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/my_appbar.dart';
import '../../components/my_button.dart';
import '../../components/my_text_field.dart';

const List<String> muscleGroups = [
  'Chest',
  'Back',
  'Shoulders',
  'Arms',
  'Legs',
  'Core',
];

class AdminExercisesPage extends StatelessWidget {
  const AdminExercisesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(
        showBackButton: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('exercises').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No exercises found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var exercise = snapshot.data!.docs[index];
              var exerciseData = exercise.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(
                  exerciseData['title'] ?? 'Untitled Exercise',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Muscle Group: ${exerciseData['muscleGroup'] ?? 'Not specified'}',
                  style: const TextStyle(color: Colors.grey),
                ),
                leading: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, exercise),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, exercise),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot exercise) {
    final exerciseData = exercise.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: exerciseData['title']);
    String selectedMuscleGroup = exerciseData['muscleGroup'] ?? muscleGroups.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Edit Exercise', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                controller: titleController,
                hintText: 'Exercise Title',
                obscureText: false,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedMuscleGroup,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
                dropdownColor: Colors.grey[800],
                items: muscleGroups.map((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedMuscleGroup = newValue;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                _updateExercise(
                  context,
                  exercise.id,
                  titleController.text,
                  selectedMuscleGroup,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentSnapshot exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Exercise', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this exercise?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _deleteExercise(context, exercise.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _updateExercise(BuildContext context, String id, String title, String muscleGroup) {
    if (title.isEmpty || muscleGroup.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and Muscle Group cannot be empty')),
      );
      return;
    }

    FirebaseFirestore.instance.collection('exercises').doc(id).update({
      'title': title,
      'muscleGroup': muscleGroup,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exercise updated successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update exercise: $error')),
      );
    });
  }

  void _deleteExercise(BuildContext context, String id) {
    FirebaseFirestore.instance.collection('exercises').doc(id).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exercise deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete exercise: $error')),
      );
    });
  }
}

