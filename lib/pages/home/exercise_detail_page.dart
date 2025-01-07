import 'package:flutter/material.dart';
import '../../components/my_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final String exerciseId;

  const ExerciseDetailPage({
    Key? key,
    required this.exercise,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<String> howToSteps;
  late Map<String, String> usefulTips;

  final Map<String, Map<String, dynamic>> exerciseInstructions = {
    'Bench Press': {
      'steps': [
        'Lie on the bench with your eyes under the bar',
        'Grip the bar with hands slightly wider than shoulder-width',
        'Unrack the bar and lower it to your mid-chest',
        'Press the bar back up to the starting position',
      ],
      'tips': {
        'Grip': 'Keep your wrists straight and knuckles facing the ceiling',
        'Breathing': 'Inhale as you lower the bar, exhale as you press up',
        'Form': 'Keep your feet flat on the ground and maintain a slight arch in your lower back',
      },
    },
    'Shoulder Press': {
      'steps': [
        'Stand with feet shoulder-width apart',
        'Hold the bar at shoulder level with an overhand grip',
        'Press the bar overhead until your arms are fully extended',
        'Lower the bar back to shoulder level',
      ],
      'tips': {
        'Core': 'Keep your core tight to maintain stability',
        'Elbows': 'Keep your elbows slightly in front of the bar as you press',
        'Head': 'Move your head back slightly as you press to avoid hitting your chin',
      },
    },
    'Dumbbell Bicep Curl': {
      'steps': [
        'Stand with feet shoulder-width apart, holding dumbbells at your sides',
        'Keep your elbows close to your torso',
        'Curl the weights up towards your shoulders',
        'Lower the weights back down to the starting position',
      ],
      'tips': {
        'Control': 'Avoid swinging the weights; use controlled movements',
        'Wrists': 'Keep your wrists straight throughout the movement',
        'Range': 'Fully extend your arms at the bottom of the movement',
      },
    },
    'Deadlift': {
      'steps': [
        'Stand with feet hip-width apart, toes under the bar',
        'Bend at the hips and knees to lower your body, grasp the bar',
        'Lift the bar by extending your hips and knees',
        'Lower the bar back to the ground with a controlled movement',
      ],
      'tips': {
        'Back': 'Keep your back straight throughout the entire movement',
        'Arms': 'Keep your arms straight; they should only hold the weight',
        'Feet': 'Keep your feet flat on the ground throughout the lift',
      },
    },
    'Bulgarian Split Squat': {
      'steps': [
        'Stand about 2 feet in front of a bench, placing one foot on it',
        'Lower your body by bending your front knee and lowering your hips straight down, keeping your chest up',
        'Pause when your front thigh is parallel to the ground, ensuring your knee doesn’t go past your toes',
        'Push through your front heel to return to the starting position',
        'Repeat on the other leg after completing the set',
      ],
      'tips': {
        'Form': 'Maintain a neutral spine and avoid leaning forward excessively',
        'Balance': 'Focus on balancing your weight evenly between both legs',
        'Core': 'Engage your core and keep your back straight to protect your lower back',
      },
    },
    'Seated Leg Curl': {
      'steps': [
        'Sit on the machine with your legs fully extended and the pads resting just above your ankles',
        'Grip the handles and adjust the seat to a comfortable position',
        'Curl your legs by bending your knees, bringing the pads towards your glutes',
        'Slowly return to the starting position with controlled movement',
      ],
      'tips': {
        'Form': 'Keep your upper body still and avoid using momentum',
        'Breathing': 'Exhale as you curl your legs and inhale as you return',
      },
    },
    'Leg Extension': {
      'steps': [
        'Sit on the machine with your back against the pad and knees slightly bent',
        'Place your feet under the lower pad with your legs bent at a 90-degree angle',
        'Extend your legs fully, then slowly return to the starting position',
      ],
      'tips': {
        'Form': 'Avoid locking your knees at the top of the movement',
        'Breathing': 'Exhale as you extend your legs, inhale as you return',
      },
    },
    'Calf Raises': {
      'steps': [
        'Stand with your feet shoulder-width apart, toes pointing forward',
        'Push through the balls of your feet to raise your heels off the ground',
        'Pause briefly at the top, then lower your heels back down',
      ],
      'tips': {
        'Form': 'Keep your core engaged and your back straight',
        'Breathing': 'Exhale as you raise, inhale as you lower',
      },
    },
    'Incline Dumbbell Press': {
      'steps': [
        'Lie back on an incline bench, holding a dumbbell in each hand',
        'Press the dumbbells up above your chest with arms fully extended',
        'Lower the dumbbells slowly until your elbows are at a 90-degree angle',
        'Press the dumbbells back to the starting position',
      ],
      'tips': {
        'Form': 'Keep your feet flat on the floor and maintain a slight arch in your lower back',
        'Breathing': 'Exhale as you press up, inhale as you lower the weights',
      },
    },
    'Cable Flyes': {
      'steps': [
        'Stand between two cable machines with the handles in each hand',
        'Extend your arms out to the sides with a slight bend in your elbows',
        'Bring your hands together in front of you, squeezing your chest at the top',
        'Slowly return to the starting position',
      ],
      'tips': {
        'Form': 'Avoid locking your elbows and maintain tension in the chest',
        'Breathing': 'Exhale as you bring the handles together, inhale as you return',
      },
    },
    'Pushups': {
      'steps': [
        'Start in a plank position with your hands placed slightly wider than shoulder-width apart',
        'Lower your body by bending your elbows until your chest nearly touches the ground',
        'Push through your palms to return to the starting position',
      ],
      'tips': {
        'Form': 'Keep your body in a straight line from head to heels',
        'Core': 'Engage your core throughout the movement to avoid sagging your hips',
      },
    },
    'Sit-ups': {
      'steps': [
        'Lie on your back with your knees bent and feet flat on the ground',
        'Cross your arms over your chest or place your hands behind your head',
        'Engage your core and lift your torso toward your knees',
        'Lower back down with control to the starting position',
      ],
      'tips': {
        'Core': 'Focus on engaging your core rather than pulling on your neck',
        'Breathing': 'Exhale as you lift your torso, inhale as you lower it',
      },
    },
    'Pull-ups': {
      'steps': [
        'Grip the pull-up bar with your palms facing away from you (overhand grip)',
        'Hang with your arms fully extended and your body straight',
        'Pull your body up by bending your elbows, bringing your chin above the bar',
        'Lower your body back down with control',
      ],
      'tips': {
        'Form': 'Engage your core and avoid swinging your legs',
        'Breathing': 'Exhale as you pull yourself up, inhale as you lower',
      },
    },
    'Bent Over Rows': {
      'steps': [
        'Stand with your feet shoulder-width apart and hold a barbell with an overhand grip',
        'Bend your knees slightly and hinge forward at the hips',
        'Pull the barbell towards your lower chest, squeezing your shoulder blades together',
        'Lower the barbell back down with control',
      ],
      'tips': {
        'Form': 'Keep your back flat and avoid rounding your spine',
        'Breathing': 'Exhale as you pull the barbell up, inhale as you lower',
      },
    },
    'Lat Pulldowns': {
      'steps': [
        'Sit at the machine with your knees secured under the pads',
        'Grip the bar with your palms facing away from you',
        'Pull the bar down towards your chest, squeezing your shoulder blades together',
        'Slowly return the bar to the starting position',
      ],
      'tips': {
        'Form': 'Keep your chest up and avoid leaning back too far',
        'Breathing': 'Exhale as you pull the bar down, inhale as you return it',
      },
    },
    'Leg Press': {
      'steps': [
        'Sit on the leg press machine with your feet shoulder-width apart on the platform',
        'Lower the platform by bending your knees to a 90-degree angle',
        'Push through your heels to return the platform to the starting position',
      ],
      'tips': {
        'Form': 'Keep your knees aligned with your toes and avoid locking your knees',
        'Breathing': 'Exhale as you push the platform, inhale as you lower it',
      },
    },
    'Romanian Deadlift': {
      'steps': [
        'Stand with your feet hip-width apart and hold a barbell with an overhand grip',
        'Hinge at the hips, lowering the barbell along the front of your legs while keeping your back straight',
        'Lower the barbell until you feel a stretch in your hamstrings, then return to the starting position',
      ],
      'tips': {
        'Form': 'Keep your back flat and avoid rounding your spine',
        'Breathing': 'Exhale as you lower the bar, inhale as you return to standing',
      },
    },
    'Military Press': {
      'steps': [
        'Sit or stand with your feet shoulder-width apart and hold a barbell at shoulder height',
        'Press the barbell overhead with arms fully extended',
        'Lower the barbell back to shoulder height with control',
      ],
      'tips': {
        'Form': 'Avoid arching your back excessively, and keep your core engaged',
        'Breathing': 'Exhale as you press up, inhale as you lower the bar',
      },
    },
    'Front Raises': {
      'steps': [
        'Stand with your feet shoulder-width apart and hold a dumbbell in each hand',
        'Lift the dumbbells in front of you to shoulder height, keeping a slight bend in your elbows',
        'Lower the dumbbells back to the starting position with control',
      ],
      'tips': {
        'Form': 'Avoid swinging the weights and focus on controlled movements',
        'Breathing': 'Exhale as you raise the dumbbells, inhale as you lower them',
      },
    },
    'Face Pulls': {
      'steps': [
        'Stand facing a cable machine with the rope attachment set at upper chest height',
        'Grip the rope with both hands, and step back to create tension on the cable',
        'Pull the rope towards your face, keeping your elbows high and squeezing your shoulder blades together',
        'Slowly return the rope to the starting position',
      ],
      'tips': {
        'Form': 'Focus on using your rear deltoids and upper back muscles',
        'Breathing': 'Exhale as you pull the rope, inhale as you return it',
      },
    },
    'Barbell Curls': {
      'steps': [
        'Stand with your feet shoulder-width apart and hold a barbell with an underhand grip',
        'Curl the barbell towards your chest by bending your elbows, keeping your upper arms stationary',
        'Lower the barbell back to the starting position with control',
      ],
      'tips': {
        'Form': 'Avoid using momentum and keep your elbows close to your body',
        'Breathing': 'Exhale as you curl the bar, inhale as you lower it',
      },
    },
    'Hammer Curls': {
      'steps': [
        'Stand with your feet shoulder-width apart and hold a dumbbell in each hand with a neutral grip',
        'Curl the dumbbells towards your shoulders, keeping your elbows stationary',
        'Lower the dumbbells back down with control',
      ],
      'tips': {
        'Form': 'Avoid swinging the dumbbells and focus on your biceps',
        'Breathing': 'Exhale as you curl the dumbbells, inhale as you lower them',
      },
    },
    'Skull Crushers': {
      'steps': [
        'Lie on a bench and hold a barbell with an overhand grip, arms extended straight above your chest',
        'Lower the barbell towards your forehead by bending your elbows',
        'Extend your arms back to the starting position',
      ],
      'tips': {
        'Form': 'Keep your elbows stationary and avoid flaring them out',
        'Breathing': 'Exhale as you extend your arms, inhale as you lower the bar',
      },
    },
    'Rows': {
      'steps': [
        'Stand with your feet shoulder-width apart and hold a barbell with an overhand grip',
        'Bend forward at the hips with your back flat and pull the barbell towards your torso',
        'Lower the barbell back down with control',
      ],
      'tips': {
        'Form': 'Engage your back muscles and avoid shrugging your shoulders',
        'Breathing': 'Exhale as you pull the bar, inhale as you lower it',
      },
    },
    'Overhead Press': {
      'steps': [
        'Stand with your feet shoulder-width apart and hold a barbell at shoulder height',
        'Press the barbell overhead with arms fully extended',
        'Lower the barbell back to shoulder height with control',
      ],
      'tips': {
        'Form': 'Engage your core to prevent excessive arching in your lower back',
        'Breathing': 'Exhale as you press the bar, inhale as you lower it',
      },
    },
    'Incline Press': {
      'steps': [
        'Set the bench to an incline and lie back, holding a barbell or dumbbells',
        'Press the weights above your chest with your arms fully extended',
        'Lower the weights to shoulder level, then press them back up',
      ],
      'tips': {
        'Form': 'Avoid letting your shoulders rise during the press',
        'Breathing': 'Exhale as you press up, inhale as you lower',
      },
    },
    'Lunges': {
      'steps': [
        'Stand with your feet hip-width apart and take a step forward with one leg',
        'Lower your body by bending both knees until the back knee is just above the floor',
        'Push through the front foot to return to the starting position',
        'Repeat with the other leg',
      ],
      'tips': {
        'Form': 'Keep your torso upright and avoid letting your front knee extend past your toes',
        'Breathing': 'Exhale as you step forward, inhale as you return',
      },
    },
    'Front Squats': {
      'steps': [
        'Stand with your feet shoulder-width apart and a barbell resting on your front deltoids',
        'Brace your core and squat down by bending your knees and hips',
        'Lower until your thighs are parallel to the floor or deeper if comfortable',
        'Push through your heels to return to standing',
      ],
      'tips': {
        'Form': 'Keep your chest up and back straight to avoid rounding your spine',
        'Breathing': 'Exhale as you rise, inhale as you lower',
      },
    },
    'Hip Thrusts': {
      'steps': [
        'Sit on the floor with your upper back against a bench and a barbell across your hips',
        'Roll the barbell into position and plant your feet flat on the floor',
        'Drive through your heels to lift your hips towards the ceiling',
        'Lower your hips back down with control',
      ],
      'tips': {
        'Form': 'Keep your chin tucked and avoid overextending your lower back',
        'Breathing': 'Exhale as you thrust your hips up, inhale as you lower them',
      },
    },
    'Pec Fly': {
      'steps': [
        'Sit on a pec fly machine or lie on a bench holding dumbbells',
        'Extend your arms out to the sides with a slight bend in your elbows',
        'Bring your arms together in front of you, squeezing your chest at the top',
        'Slowly return to the starting position',
      ],
      'tips': {
        'Form': 'Avoid locking your elbows and keep tension on the chest throughout',
        'Breathing': 'Exhale as you bring your arms together, inhale as you return',
      },
    },
    'Lateral Raise': {
      'steps': [
        'Stand with your feet shoulder-width apart and hold a dumbbell in each hand',
        'Raise your arms out to the sides until they reach shoulder height',
        'Lower your arms back down with control',
      ],
      'tips': {
        'Form': 'Keep a slight bend in your elbows and avoid swinging the weights',
        'Breathing': 'Exhale as you raise the dumbbells, inhale as you lower them',
      },
    },
    'Tricep Pushdown': {
      'steps': [
        'Stand facing a cable machine with the rope attachment set at the top',
        'Grip the rope with both hands and pull it down until your elbows are at your sides',
        'Push the rope down by extending your arms fully',
        'Slowly return the rope to the starting position',
      ],
      'tips': {
        'Form': 'Keep your elbows locked in place and avoid leaning forward',
        'Breathing': 'Exhale as you push the rope down, inhale as you return it',
      },
    },
    'Seated Cable Row': {
      'steps': [
        'Sit at a cable row machine with your feet on the platform and hands gripping the handle',
        'Pull the handle towards your torso, squeezing your shoulder blades together',
        'Slowly return the handle to the starting position',
      ],
      'tips': {
        'Form': 'Keep your chest up and avoid leaning back excessively',
        'Breathing': 'Exhale as you pull the handle, inhale as you return',
      },
    },
    'Squat': {
      'steps': [
        'Stand with your feet shoulder-width apart and a barbell resting on your upper back',
        'Brace your core and squat down by bending your knees and hips',
        'Lower until your thighs are parallel to the floor or deeper if comfortable',
        'Push through your heels to return to standing',
      ],
      'tips': {
        'Form': 'Keep your chest up, back straight, and knees tracking over your toes',
        'Breathing': 'Exhale as you rise, inhale as you lower',
      },
    },
  };

  Future<List<Map<String, dynamic>>> fetchExerciseHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('completed_workouts')
          .where('userId', isEqualTo: userId)
          .get();

      final documents = querySnapshot.docs;
      documents.sort((a, b) => (b.data()['date'] as Timestamp)
          .compareTo(a.data()['date'] as Timestamp));

      List<Map<String, dynamic>> sessions = [];

      for (var doc in documents) {
        if (sessions.length >= 5) break;

        final data = doc.data();
        final exercises = data['exercises'] as List<dynamic>;

        for (var exercise in exercises) {
          if (exercise['title'] == widget.exercise['title']) {
            final sets = exercise['sets'] as List<dynamic>;
            if (sets.isNotEmpty) {
              sessions.add({
                'day': _formatDate((data['date'] as Timestamp).toDate()),
                'date': _formatDateShort((data['date'] as Timestamp).toDate()),
                'sets': sets.map((set) => {
                  'set': set['set'].toString(),
                  'reps': set['reps'].toString(),
                  'weight': set['weight'].toString(),
                }).toList(),
              });
            }
            break;
          }
        }
      }

      return sessions;
    } catch (e) {
      print('Error fetching exercise history: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeExerciseInstructions();
  }

  void _initializeExerciseInstructions() {
    final exerciseTitle = widget.exercise['title'] as String;
    final instructions = exerciseInstructions[exerciseTitle];

    if (instructions != null) {
      howToSteps = instructions['steps'] as List<String>;
      usefulTips = Map<String, String>.from(instructions['tips'] as Map);
    } else {
      howToSteps = ['Instructions not available for this exercise'];
      usefulTips = {'Note': 'Tips not available for this exercise'};
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Useful Tips',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: usefulTips.entries
              .map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.key,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.value,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Set',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Reps',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'kg',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetItem(Map<String, dynamic> set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              set['set'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              set['reps'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              set['weight'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session['day'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                session['date'],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        _buildHistoryHeader(),
        ...(session['sets'] as List<Map<String, dynamic>>).map(_buildSetItem),
        Divider(
          color: Colors.grey[800],
          height: 32,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(showBackButton: true),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'How to'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Summary Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                widget.exercise['icon'] as IconData,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.exercise['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchExerciseHistory(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('No history available',
                                  style: TextStyle(color: Colors.grey));
                            } else {
                              return Column(
                                children: snapshot.data!
                                    .map((session) => _buildSessionItem(session))
                                    .toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // How to Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...howToSteps.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            '${entry.key + 1}. ${entry.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )).toList(),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: _showTipsDialog,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.help_outline,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Useful Tips',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

