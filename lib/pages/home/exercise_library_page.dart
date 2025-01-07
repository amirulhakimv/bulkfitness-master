import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/my_appbar.dart';
import '../tips/user_add_exercise_page.dart';
import 'exercise_detail_page.dart';

class ExerciseLibraryPage extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onExercisesSelected;
  final bool multiSelect;
  final List<Map<String, dynamic>> initialSelectedExercises;
  final Map<String, dynamic>? exerciseToSwap;

  const ExerciseLibraryPage({
    Key? key,
    required this.onExercisesSelected,
    this.multiSelect = false,
    this.initialSelectedExercises = const [],
    this.exerciseToSwap,
  }) : super(key: key);

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedMuscleGroup;
  late List<Map<String, dynamic>> selectedExercises;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
  ];

  List<Map<String, dynamic>> allExercises = [
    // ... (keep all the existing exercise data)
  ];

  @override
  void initState() {
    super.initState();
    selectedExercises = List.from(widget.initialSelectedExercises);
    _initializeExercises();
  }

  Future<void> _initializeExercises() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loadExercises();
    } catch (e) {
      print('Error initializing exercises: $e');
      setState(() {
        _errorMessage = 'Failed to initialize exercises. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExercises() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final QuerySnapshot defaultExerciseSnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .get();

      List<QueryDocumentSnapshot> userExerciseDocs = [];
      if (user != null) {
        final QuerySnapshot userExerciseSnapshot = await FirebaseFirestore.instance
            .collection('user_exercises')
            .where('userId', isEqualTo: user.uid)
            .get();
        userExerciseDocs = userExerciseSnapshot.docs;
      }

      print('Loaded ${defaultExerciseSnapshot.docs.length} default exercises and ${userExerciseDocs.length} user exercises from Firestore');

      final List<Map<String, dynamic>> firestoreExercises = [
        ...defaultExerciseSnapshot.docs,
        ...userExerciseDocs,
      ].map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': data['id'] ?? doc.id,
          'title': data['title'] ?? '',
          'icon': _getIconData(data['icon']?.toString() ?? 'fitness_center'),
          'muscleGroup': data['muscleGroup'] ?? '',
          'sets': (data['sets'] as List<dynamic>?)?.map((set) => {
            'set': set['set'] ?? 1,
            'weight': set['weight'] ?? 0,
            'reps': set['reps'] ?? '0',
            'multiplier': set['multiplier'] ?? 'x',
          }).toList() ?? [{'set': 1, 'weight': 0, 'reps': '0', 'multiplier': 'x'}],
          'isUserCreated': data['userId'] != null,
        };
      }).toList();

      setState(() {
        allExercises = firestoreExercises;
      });
    } catch (e) {
      print('Error loading exercises: $e');
      throw e;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.fitness_center;
    }
  }

  List<Map<String, dynamic>> get filteredExercises {
    return allExercises.where((exercise) {
      final matchesSearch = exercise['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMuscle = _selectedMuscleGroup == null || exercise['muscleGroup'] == _selectedMuscleGroup;
      return matchesSearch && matchesMuscle;
    }).toList();
  }

  void _showMuscleGroupFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Filter by Muscle Group',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a muscle group to filter exercises:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...muscleGroups.map((group) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMuscleGroup == group ? Colors.blue : Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      group,
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (_selectedMuscleGroup == group)
                      const Icon(Icons.check, color: Colors.white),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _selectedMuscleGroup = _selectedMuscleGroup == group ? null : group;
                  });
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              child: const Text(
                'Clear Filter',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
              onPressed: () {
                setState(() {
                  _selectedMuscleGroup = null;
                });
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToExerciseDetail(Map<String, dynamic> exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailPage(
          exercise: exercise,
          exerciseId: exercise['id'],
        ),
      ),
    );
  }

  void _navigateToUserAddExercisePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserAddExercisePage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        allExercises.add(result);
      });
    }
  }

  Widget buildExerciseItem(Map<String, dynamic> exercise) {
    bool isAlreadyAdded = widget.initialSelectedExercises.any((e) => e['title'] == exercise['title']);
    bool isSelected = selectedExercises.any((e) => e['title'] == exercise['title']);
    bool isExerciseToSwap = widget.exerciseToSwap != null && widget.exerciseToSwap!['title'] == exercise['title'];

    return ListTile(
      leading: GestureDetector(
        onTap: () => _navigateToExerciseDetail(exercise),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            exercise['icon'] as IconData,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () => _navigateToExerciseDetail(exercise),
        child: Row(
          children: [
            Expanded(
              child: Text(
                exercise['title'] as String,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (isAlreadyAdded && !isExerciseToSwap) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Added',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
            if (isExerciseToSwap) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Current',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
      trailing: widget.exerciseToSwap != null
          ? (isExerciseToSwap
          ? const Icon(Icons.swap_horiz, color: Colors.orange)
          : IconButton(
        icon: const Icon(Icons.swap_horiz, color: Colors.white),
        onPressed: isAlreadyAdded
            ? null
            : () {
          widget.onExercisesSelected([exercise]);
          Navigator.pop(context);
        },
      ))
          : (widget.multiSelect
          ? Checkbox(
        value: isSelected,
        onChanged: isAlreadyAdded && !isExerciseToSwap
            ? null
            : (bool? value) {
          setState(() {
            if (value == true) {
              if (!isSelected) {
                selectedExercises.add(exercise);
              }
            } else {
              selectedExercises.removeWhere((e) => e['title'] == exercise['title']);
            }
          });
        },
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey[600];
          }
          if (states.contains(MaterialState.selected)) {
            return Colors.blue;
          }
          return Colors.grey;
        }),
      )
          : IconButton(
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: isAlreadyAdded
            ? null
            : () {
          widget.onExercisesSelected([exercise]);
          Navigator.pop(context);
        },
        color: isAlreadyAdded ? Colors.grey : Colors.white,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(
        showBackButton: true,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: _initializeExercises,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48, // Set a fixed height to match the button
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search Exercises',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[800],
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: _navigateToUserAddExercisePage,
                          tooltip: 'Add Custom Exercises',
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48, // Set the same height as the search bar
                  child: ElevatedButton.icon(
                    onPressed: _showMuscleGroupFilter,
                    icon: Icon(
                      Icons.filter_list,
                      color: _selectedMuscleGroup != null ? Colors.blue : Colors.white,
                    ),
                    label: Text(
                      _selectedMuscleGroup ?? 'Filter',
                      style: TextStyle(
                        color: _selectedMuscleGroup != null ? Colors.blue : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Exercises',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filteredExercises.map((exercise) => buildExerciseItem(exercise)).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.multiSelect
          ? FloatingActionButton(
        child: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.blue,
        onPressed: () {
          widget.onExercisesSelected(selectedExercises);
          Navigator.pop(context);
        },
      )
          : null,
    );
  }
}

