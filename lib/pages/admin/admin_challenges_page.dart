import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/my_appbar.dart';
import '../../components/my_button.dart';
import '../../components/my_text_field.dart';
import '../../components/my_custom_calendar.dart';
import '../home/exercise_library_page.dart';
import 'add_challenge_page.dart';

class AdminChallengesPage extends StatefulWidget {
  const AdminChallengesPage({Key? key}) : super(key: key);

  @override
  _AdminChallengesPageState createState() => _AdminChallengesPageState();
}

class _AdminChallengesPageState extends State<AdminChallengesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<Map<String, dynamic>> _selectedExercises = [];
  bool _isEditing = false;
  String? _editingChallengeId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(
        showBackButton: true,
      ),
      body: _isEditing ? _buildEditForm() : _buildChallengesList(),
    );
  }

  Widget _buildChallengesList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey[600]),
                hintText: 'Search challenges',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('challenges').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No challenges found.'));
              }

              final challenges = snapshot.data!.docs
                  .where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['title'].toString().toLowerCase().contains(_searchQuery) ||
                    data['description'].toString().toLowerCase().contains(_searchQuery);
              })
                  .toList();

              return ListView.builder(
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  var challenge = challenges[index];
                  var challengeData = challenge.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      challengeData['title'] ?? 'Untitled Challenge',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Exercises: ${(challengeData['exercises'] as List?)?.length ?? 0}',
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
                          onPressed: () => _startEditing(challenge),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, challenge),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Challenge Title',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
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
              SizedBox(height: 16),
              Text(
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
              SizedBox(height: 16),
              Text(
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
              SizedBox(height: 24),
              Text(
                'Selected Exercises:',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _selectedExercises.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _selectedExercises[index]['title'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedExercises.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _navigateToExerciseLibrary,
                  child: Text('Add Exercises'),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _updateChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Update Challenge',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startEditing(DocumentSnapshot challenge) {
    final challengeData = challenge.data() as Map<String, dynamic>;
    setState(() {
      _isEditing = true;
      _editingChallengeId = challenge.id;
      _titleController.text = challengeData['title'] ?? '';
      _descriptionController.text = challengeData['description'] ?? '';
      _selectedExercises = List<Map<String, dynamic>>.from(challengeData['exercises'] ?? []);
      _startDate = (challengeData['startDate'] as Timestamp).toDate();
      _endDate = (challengeData['endDate'] as Timestamp).toDate();
    });
  }

  void _navigateToExerciseLibrary() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseLibraryPage(
          onExercisesSelected: (exercises) {
            setState(() {
              _selectedExercises = exercises;
            });
          },
          multiSelect: true,
          initialSelectedExercises: _selectedExercises,
        ),
      ),
    );
  }

  Future<void> _updateChallenge() async {
    if (_formKey.currentState!.validate() && _selectedExercises.isNotEmpty) {
      try {
        final sanitizedExercises = _selectedExercises.map((exercise) => {
          'id': exercise['id'],
          'title': exercise['title'],
        }).toList();

        await FirebaseFirestore.instance.collection('challenges').doc(_editingChallengeId).update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'exercises': sanitizedExercises,
          'startDate': Timestamp.fromDate(_startDate),
          'endDate': Timestamp.fromDate(_endDate),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Challenge updated successfully')),
        );

        setState(() {
          _isEditing = false;
          _editingChallengeId = null;
          _titleController.clear();
          _descriptionController.clear();
          _selectedExercises.clear();
          _startDate = DateTime.now();
          _endDate = DateTime.now().add(const Duration(days: 7));
        });
      } catch (e) {
        print('Error updating challenge: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating challenge. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and add at least one exercise'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, DocumentSnapshot challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Challenge', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this challenge?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _deleteChallenge(context, challenge.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deleteChallenge(BuildContext context, String id) {
    FirebaseFirestore.instance.collection('challenges').doc(id).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete challenge: $error')),
      );
    });
  }
}

