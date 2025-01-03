import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bulkfitness/components/my_appbar.dart';
import 'package:bulkfitness/components/my_custom_calendar.dart';
import 'package:bulkfitness/pages/home/exercise_library_page.dart';

class AddChallengePage extends StatefulWidget {
  const AddChallengePage({Key? key}) : super(key: key);

  @override
  _AddChallengePageState createState() => _AddChallengePageState();
}

class _AddChallengePageState extends State<AddChallengePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> selectedExercises = [];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _submitChallenge() async {
    if (_formKey.currentState!.validate() && selectedExercises.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final sanitizedExercises = selectedExercises.map((exercise) => {
          'id': exercise['id'],
          'title': exercise['title'],
        }).toList();

        await FirebaseFirestore.instance.collection('challenges').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'exercises': sanitizedExercises,
          'startDate': Timestamp.fromDate(_startDate),
          'endDate': Timestamp.fromDate(_endDate),
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': FirebaseAuth.instance.currentUser?.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Challenge added successfully')),
        );

        // Clear the form
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          selectedExercises = [];
          _startDate = DateTime.now();
          _endDate = DateTime.now().add(const Duration(days: 7));
        });
      } catch (e) {
        print('Error adding challenge: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding challenge. Please try again.')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and add at least one exercise'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Challenge',
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
                      labelText: 'Challenge Title',
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
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Description',
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
                    maxLength: 1000,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Start Date:',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  MyCustomCalendar(
                    initialDate: _startDate,
                    onDateChanged: (date) {
                      setState(() {
                        _startDate = date;
                        if (_endDate.isBefore(_startDate)) {
                          _endDate = _startDate.add(const Duration(days: 1));
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'End Date:',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  MyCustomCalendar(
                    initialDate: _endDate,
                    onDateChanged: (date) {
                      setState(() {
                        if (date.isAfter(_startDate)) {
                          _endDate = date;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('End date must be after start date'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      });
                    },
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
                      onPressed: _submitChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        'Save Challenge',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

