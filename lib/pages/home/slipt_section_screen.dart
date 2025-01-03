import 'dart:convert';

import 'package:bulkfitness/components/customText.dart';
import 'package:bulkfitness/components/my_appbar.dart';
import 'package:bulkfitness/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplitSectionScreen extends StatefulWidget {
  const SplitSectionScreen({super.key});

  @override
  State<SplitSectionScreen> createState() => _SplitSectionScreenState();
}

class _SplitSectionScreenState extends State<SplitSectionScreen> {
  List<Map<String, dynamic>> selectedExercises = [];

  @override
  void initState() {
    super.initState();
    loadSelectedExercises();
  }

  // Load selected exercises from SharedPreferences
  Future<void> loadSelectedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exercises = prefs.getStringList('selected_exercises') ?? [];
    setState(() {
      selectedExercises = exercises.map((e) {
        final exercise = jsonDecode(e) as Map<String, dynamic>;
        exercise['selected'] = exercise['selected'] ?? false; // Ensure the key exists
        return exercise;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: selectedExercises.isEmpty
          ? const Center(child: Text("No exercises selected.", style: TextStyle(color: Colors.white)))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: selectedExercises.length,
                itemBuilder: (context, index) {
                  final exercise = selectedExercises[index];
                  return Card(
                    color: Colors.white24,
                    child: ListTile(
                      title: Text(
                        "${exercise['category']}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${exercise['title']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exercise['exercises']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddSplitsScreen and wait for a result
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSplitsScreen()),
          );
          // After returning, reload the exercises from SharedPreferences
          loadSelectedExercises();
        },
        shape: CircleBorder(),
        backgroundColor: Colors.white10,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AddSplitsScreen extends StatefulWidget {
  const AddSplitsScreen({super.key});

  @override
  State<AddSplitsScreen> createState() => _AddSplitsScreenState();
}

class _AddSplitsScreenState extends State<AddSplitsScreen> {
  final Map<String, List<Map<String, String>>> workoutData = {
    'PPL': [
      {
        'title': 'Push Day 1',
        'exercises': 'Bench Press, Shoulder Press,\nPec Fly, Lateral Raise, Tricep Pushdown',
      },
      {
        'title': 'Pull Day 1',
        'exercises': 'Deadlift, Lat Pulldown, Seated\nCable Row, Dumbbell Bicep Curl',
      },
      {
        'title': 'Leg Day 1',
        'exercises': 'Squat, Bulgarian Split Squat,\nSeated Leg Curl, Leg Extension, Calf Raises',
      },
    ],
    'Bro Split': [
      {
        'title': 'Chest Day',
        'exercises': 'Bench Press, Incline Dumbbell Press,\nCable Flyes, Pushups',
      },
      {
        'title': 'Back Day',
        'exercises': 'Deadlifts, Pull-ups, Bent Over Rows,\nLat Pulldowns',
      },
      {
        'title': 'Leg Day',
        'exercises': 'Squats, Leg Press, Romanian Deadlifts,\nLeg Extensions, Calf Raises',
      },
      {
        'title': 'Shoulder Day',
        'exercises': 'Military Press, Lateral Raises,\nFront Raises, Face Pulls',
      },
      {
        'title': 'Arm Day',
        'exercises': 'Barbell Curls, Tricep Pushdowns,\nHammer Curls, Skull Crushers',
      },
    ],
    'Upper / Lower': [
      {
        'title': 'Upper Day 1',
        'exercises': 'Bench Press, Rows, Overhead Press,\nLat Pulldowns, Bicep Curls, Tricep Extensions',
      },
      {
        'title': 'Lower Day 1',
        'exercises': 'Squats, Romanian Deadlifts,\nLeg Press, Leg Curls, Calf Raises',
      },
      {
        'title': 'Upper Day 2',
        'exercises': 'Incline Press, Pull-ups, Lateral Raises,\nFace Pulls, Hammer Curls, Tricep Pushdowns',
      },
      {
        'title': 'Lower Day 2',
        'exercises': 'Deadlifts, Front Squats,\nLunges, Leg Extensions, Hip Thrusts',
      },
    ],
  };

  List<Map<String, dynamic>> selectedExercises = [];

  @override
  void initState() {
    super.initState();
    loadSelectedExercises();
  }

  // Save selected exercises to SharedPreferences
  Future<void> saveSelectedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exercises = selectedExercises.map((exercise) {
      return jsonEncode({
        'category': exercise['category'],
        'title': exercise['title'],
        'exercises': exercise['exercises'],
        'selected': exercise['selected'], // Save the selected status
      });
    }).toList();
    await prefs.setStringList('selected_exercises', exercises);
  }

  // Load selected exercises from SharedPreferences
  Future<void> loadSelectedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final savedExercises = prefs.getStringList('selected_exercises') ?? [];
    setState(() {
      selectedExercises = savedExercises.map((e) {
        final exercise = jsonDecode(e) as Map<String, dynamic>;
        exercise['selected'] = exercise['selected'] ?? false; // Ensure the key exists
        return exercise;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: workoutData.entries.map((entry) {
            final category = entry.key;
            final exercises = entry.value;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white24,
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ExpansionTile(
                title: CustomText(text: category, color: Colors.white),
                children: exercises.map((exercise) {
                  final isSelected = selectedExercises.any(
                    (e) => e['title'] == exercise['title'] && e['category'] == category && e['selected'] == true,
                  );

                  return ListTile(
                    tileColor: Colors.white10,
                    trailing: IconButton(
                      icon: Icon(
                        isSelected ? Icons.check_circle : Icons.add_circle_outline,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            // Unselect the exercise
                            selectedExercises.removeWhere(
                              (e) => e['title'] == exercise['title'] && e['category'] == category,
                            );
                          } else {
                            // Select the exercise
                            selectedExercises.add({
                              'category': category,
                              'title': exercise['title']!,
                              'exercises': exercise['exercises']!,
                              'selected': true, // Mark as selected
                            });
                          }
                          saveSelectedExercises();
                        });
                      },
                    ),
                    title: CustomText(
                      text: exercise['title']!,
                      color: Colors.white,
                      fontSize: responsive(16, context),
                    ),
                    subtitle: CustomText(text: exercise['exercises']!, color: Colors.grey),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
