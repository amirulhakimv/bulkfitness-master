import 'package:bulkfitness/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bulkfitness/components/my_appbar.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedSex = 'M';
  String? _selectedActivityLevel;
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  double _currentWeight = 54.0;
  double _goalWeight = 65.0;
  double _progress = 0.0;

  List<Map<String, dynamic>> _weightHistory = [];
  List<Map<String, dynamic>> _badges = [];

  final List<String> _activityLevels = [
    'Not Active',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startListeningToUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
      await _firestore.collection('users').doc(user.uid).get();

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        setState(() {
          _currentWeight = data['currentWeight'] ?? _currentWeight;
          _goalWeight = data['goalWeight'] ?? _goalWeight;
          _updateProgress();

          _selectedSex = data['sex'] ?? 'M';
          _heightController.text = (data['height'] ?? '').toString();
          _currentWeightController.text = _currentWeight.toString();
          _goalWeightController.text = _goalWeight.toString();
          _selectedActivityLevel = data['activityLevel'];

          // Load badges
          if (data['badges'] != null) {
            _badges = List<Map<String, dynamic>>.from(data['badges']);
          }
        });

        // Load weight history
        QuerySnapshot weightHistorySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('weightHistory')
            .orderBy('date', descending: true)
            .get();

        setState(() {
          _weightHistory = weightHistorySnapshot.docs.map((doc) {
            return {
              'date': doc['date'],
              'weight': doc['weight'],
              'status': doc['status'],
              'difference': doc['difference'],
            };
          }).toList();
        });
      }
    }
  }

  void _updateProgress() {
    setState(() {
      if (_goalWeight > _currentWeight) {
        // For weight gain
        _progress = (_currentWeight - 0) / (_goalWeight - 0);
      } else {
        // For weight loss
        _progress = 1 - ((_currentWeight - _goalWeight) / _currentWeight);
      }
      _progress = _progress.clamp(0.0, 1.0);
    });
  }

  StreamSubscription? _userDataSubscription;

  void _startListeningToUserData() {
    User? user = _auth.currentUser;
    if (user != null) {
      _userDataSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          setState(() {
            if (data['badges'] != null) {
              _badges = List<Map<String, dynamic>>.from(data['badges']);
            }
          });
        }
      });
    }
  }

  Future<void> _updateGoals() async {
    double? height = double.tryParse(_heightController.text);
    double? newCurrentWeight = double.tryParse(_currentWeightController.text);
    double? goalWeight = double.tryParse(_goalWeightController.text);

    if (height != null &&
        newCurrentWeight != null &&
        goalWeight != null &&
        _selectedActivityLevel != null) {
      double bmr;
      if (_selectedSex == 'M') {
        bmr = 88.362 +
            (13.397 * newCurrentWeight) +
            (4.799 * height) -
            (5.677 * 25); // Assuming age 25
      } else {
        bmr = 447.593 +
            (9.247 * newCurrentWeight) +
            (3.098 * height) -
            (4.330 * 25);
      }

      double activityFactor = {
        'Not Active': 1.2,
        'Lightly Active': 1.375,
        'Moderately Active': 1.55,
        'Very Active': 1.725,
        'Extra Active': 1.9,
      }[_selectedActivityLevel]!;

      int goalCalories = (bmr * activityFactor).round();

      User? user = _auth.currentUser;
      if (user != null) {
        // Fetch the latest weight for comparison
        DocumentSnapshot userData =
        await _firestore.collection('users').doc(user.uid).get();

        double previousWeight = userData['currentWeight'] ?? 0.0;

        // Calculate weight difference
        double weightDifference = newCurrentWeight - previousWeight;
        String status = weightDifference > 0 ? "Gained" : "Lost";

        // Update Firestore with new weight and history
        await _firestore.collection('users').doc(user.uid).update({
          'sex': _selectedSex,
          'height': height,
          'currentWeight': newCurrentWeight,
          'goalWeight': goalWeight,
          'activityLevel': _selectedActivityLevel,
          'goalCalories': goalCalories,
        });

        // Add to weight history
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('weightHistory')
            .add({
          'date': DateTime.now().toIso8601String(),
          'weight': newCurrentWeight,
          'status': status,
          'difference': weightDifference.abs().toStringAsFixed(1),
        });

        // Update UI
        setState(() {
          _currentWeight = newCurrentWeight;
          _goalWeight = goalWeight;
          _updateProgress();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Goals updated successfully!")),
        );

        // Reload weight history
        _loadUserData();
      }

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields correctly!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: MyAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email and Badge Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Profile Picture and Email Section
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey[800],
                          child: Icon(Icons.person, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Username",
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.displayName ?? "No Username",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Badges Section
                    if (_badges.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Achievement Badges",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _badges.map((badge) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.amber[700],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.amber[300]!,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber[700]!.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.military_tech,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    badge['name'] ?? 'Challenge Badge',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(DateTime.parse(badge['earnedAt'])),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Weight Progress Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weight Progress",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${_currentWeight.toStringAsFixed(1)} kg",
                            style: TextStyle(color: Colors.grey[400])),
                        Text("${_goalWeight.toStringAsFixed(1)} kg",
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[800],
                      color: _goalWeight > _currentWeight ? Colors.green : Colors.green,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showUpdateGoalsPopup,
                      child: Text("Update Goals"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Weight History Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weight History",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _weightHistory.length,
                      itemBuilder: (context, index) {
                        final entry = _weightHistory[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['date'],
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${entry['status']} ${entry['difference']} kg",
                                    style: TextStyle(
                                      color: entry['status'] == "Gained"
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${entry['weight']} kg",
                                style:
                                TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _showLogoutConfirmation,
                    child: Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUpdateGoalsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Update Goals",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 16),
                    Text("Sex", style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _selectedSex = 'M'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedSex == 'M'
                                  ? Colors.white
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('M',
                                style: TextStyle(
                                    color: _selectedSex == 'M'
                                        ? Colors.black
                                        : Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _selectedSex = 'F'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedSex == 'F'
                                  ? Colors.white
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('F',
                                style: TextStyle(
                                    color: _selectedSex == 'F'
                                        ? Colors.black
                                        : Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Height (cm)", style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _heightController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Current Weight (kg)",
                        style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _currentWeightController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Goal Weight (kg)",
                        style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _goalWeightController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Activity Level",
                        style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    DropdownButton<String>(
                      value: _selectedActivityLevel,
                      hint: Text('Select',
                          style: TextStyle(color: Colors.grey[400])),
                      isExpanded: true,
                      dropdownColor: Colors.grey[900],
                      items: _activityLevels.map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level,
                            style: const TextStyle(color: Colors.white)),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedActivityLevel = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateGoals();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Logout Confirmation',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _userDataSubscription?.cancel();
    super.dispose();
  }
}
