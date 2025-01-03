import 'package:bulkfitness/pages/first_page.dart';
import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  String _selectedSex = 'M';
  String? _selectedActivityLevel;
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  double? _bmi;
  String _bmiDescription = '';

  final List<String> _activityLevels = [
    'Not Active',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active'
  ];

  @override
  void dispose() {
    _heightController.dispose();
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  void _getStarted() async {
    double? height = double.tryParse(_heightController.text);
    double? currentWeight = double.tryParse(_currentWeightController.text);
    double? goalWeight = double.tryParse(_goalWeightController.text);

    if (height != null &&
        currentWeight != null &&
        goalWeight != null &&
        _selectedActivityLevel != null) {
      double bmi = currentWeight / ((height / 100) * (height / 100));
      int goalCalories =
      _calculateGoalCalories(height, currentWeight, _selectedSex, _selectedActivityLevel!);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'sex': _selectedSex,
          'height': height,
          'currentWeight': currentWeight,
          'goalWeight': goalWeight,
          'activityLevel': _selectedActivityLevel,
          'bmi': bmi,
          'goalCalories': goalCalories,
        }, SetOptions(merge: true));
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FirstPage(),
      ),
    );
  }

  int _calculateGoalCalories(double height, double weight, String sex, String activityLevel) {
    double bmr;
    if (sex == 'M') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * 25); // Assuming age 25
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * 25); // Assuming age 25
    }

    double activityFactor;
    switch (activityLevel) {
      case 'Not Active':
        activityFactor = 1.2;
        break;
      case 'Lightly Active':
        activityFactor = 1.375;
        break;
      case 'Moderately Active':
        activityFactor = 1.55;
        break;
      case 'Very Active':
        activityFactor = 1.725;
        break;
      case 'Extra Active':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2;
    }

    return (bmr * activityFactor).round();
  }

  void _calculateBMI() {
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_currentWeightController.text);

    if (height != null && weight != null && height > 0) {
      double bmi = weight / ((height / 100) * (height / 100));
      setState(() {
        _bmi = bmi;
        _bmiDescription = _getBMICategory(bmi);
      });
    } else {
      setState(() {
        _bmi = null;
        _bmiDescription = '';
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Widget _buildTextField(TextEditingController controller, String suffix) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[700]!, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffix: Text(
                  suffix,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              onChanged: (_) => _calculateBMI(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[300],
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid = _heightController.text.isNotEmpty &&
        _currentWeightController.text.isNotEmpty &&
        _goalWeightController.text.isNotEmpty &&
        _selectedActivityLevel != null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.grey[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildLabel('Sex'),
                          const SizedBox(height: 8),
                          _buildGenderSelection(),
                          const SizedBox(height: 20),
                          _buildLabel('Height'),
                          const SizedBox(height: 8),
                          _buildTextField(_heightController, 'cm'),
                          const SizedBox(height: 20),
                          _buildLabel('Current Weight'),
                          const SizedBox(height: 8),
                          _buildTextField(_currentWeightController, 'kg'),
                          const SizedBox(height: 20),
                          _buildLabel('Goal Weight'),
                          const SizedBox(height: 8),
                          _buildTextField(_goalWeightController, 'kg'),
                          const SizedBox(height: 20),
                          _buildLabel('Activity Level'),
                          const SizedBox(height: 8),
                          _buildActivityLevelDropdown(),
                          const SizedBox(height: 20),
                          if (_bmi != null) _buildBMICard(),
                        ],
                      ),
                    ),
                  ),
                ),
                MyButton(
                  onTap: isFormValid ? _getStarted : null,
                  text: "GET STARTED",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['M', 'F'].map((gender) {
        bool isSelected = _selectedSex == gender;
        return GestureDetector(
          onTap: () => setState(() => _selectedSex = gender),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityLevelDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[800],
      ),
      child: DropdownButton<String>(
        value: _selectedActivityLevel,
        hint: Text(
          'Select',
          style: TextStyle(color: Colors.grey[400]),
        ),
        isExpanded: true,
        dropdownColor: Colors.grey[900],
        underline: Container(),
        style: const TextStyle(color: Colors.white),
        items: _activityLevels.map((level) {
          return DropdownMenuItem(
            value: level,
            child: Text(level),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedActivityLevel = value),
      ),
    );
  }

  Widget _buildBMICard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your BMI: ${_bmi!.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: $_bmiDescription',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
