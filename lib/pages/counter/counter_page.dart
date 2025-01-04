import 'package:bulkfitness/components/my_custom_calendar.dart';
import 'package:flutter/material.dart';
import '../../components/my_appbar.dart';
import '../../components/my_dropdown.dart';
import 'food_library_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;

  String? _selectedBreakfast;
  String? _selectedLunch;
  String? _selectedDinner;

  int _breakfastCalories = 0;
  int _lunchCalories = 0;
  int _dinnerCalories = 0;

  int _goalCalories = 2200; // Default value, will be updated from Firestore

  List<Map<String, dynamic>> _breakfastItems = [];
  List<Map<String, dynamic>> _lunchItems = [];
  List<Map<String, dynamic>> _dinnerItems = [];

  late DateTime _selectedDate;

  List<Map<String, dynamic>> _foodLibrary = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _userId = _auth.currentUser?.uid ?? 'defaultUser';
    _listenToUserGoalCalories();
    _loadDataForDate(_selectedDate);
    _loadFoodLibrary();
  }

  void _listenToUserGoalCalories() {
    _firestore.collection('users').doc(_userId).snapshots().listen((userDoc) {
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _goalCalories = userData['goalCalories'] ?? 2200;
        });
      }
    });
  }

  Future<void> _loadDataForDate(DateTime date) async {
    final docSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('meals')
        .doc(date.toIso8601String().split('T')[0])
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _breakfastItems = List<Map<String, dynamic>>.from(data['breakfast'] ?? []);
        _lunchItems = List<Map<String, dynamic>>.from(data['lunch'] ?? []);
        _dinnerItems = List<Map<String, dynamic>>.from(data['dinner'] ?? []);
        _updateCalories();
      });
    } else {
      setState(() {
        _breakfastItems = [];
        _lunchItems = [];
        _dinnerItems = [];
        _updateCalories();
      });
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadDataForDate(date);
  }

  void _updateCalories() {
    _breakfastCalories = _calculateMealCalories(_breakfastItems);
    _lunchCalories = _calculateMealCalories(_lunchItems);
    _dinnerCalories = _calculateMealCalories(_dinnerItems);
  }

  int _calculateMealCalories(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) => sum + (item['calories'] as int));
  }

  Future<void> _addFood(String mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodLibraryPage(mealType: mealType),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        switch (mealType) {
          case 'Breakfast':
            _breakfastItems.add(result);
            break;
          case 'Lunch':
            _lunchItems.add(result);
            break;
          case 'Dinner':
            _dinnerItems.add(result);
            break;
        }
        _updateCalories();
      });
      await _saveDataToFirestore();
    }
  }

  Future<void> _removeFood(String mealType, String? itemName) async {
    if (itemName == null) return;
    setState(() {
      switch (mealType) {
        case 'Breakfast':
          _breakfastItems.removeWhere((item) => item['name'] as String == itemName);
          break;
        case 'Lunch':
          _lunchItems.removeWhere((item) => item['name'] as String == itemName);
          break;
        case 'Dinner':
          _dinnerItems.removeWhere((item) => item['name'] as String == itemName);
          break;
      }
      _updateCalories();
    });
    await _saveDataToFirestore();
  }

  Future<void> _saveDataToFirestore() async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('meals')
        .doc(_selectedDate.toIso8601String().split('T')[0])
        .set({
      'breakfast': _breakfastItems,
      'lunch': _lunchItems,
      'dinner': _dinnerItems,
    });
  }

  void _showRecommendationPopup() {
    int totalCalories = _breakfastCalories + _lunchCalories + _dinnerCalories;
    int remainingCalories = _goalCalories - totalCalories;

    String title;
    Widget content;

    if (remainingCalories > 0) {
      List<Map<String, dynamic>> recommendations = _getRecommendations(remainingCalories);
      title = 'Food Recommendations';
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have $remainingCalories calories remaining.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          ...recommendations.map((food) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${food['calories']} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      );
    } else {
      List<Map<String, dynamic>> foodsToRemove = _getFoodsToRemove(-remainingCalories);
      title = 'Calorie Intake Exceeded';
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have exceeded your calorie goal by ${-remainingCalories} kcal.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Consider removing:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          ...foodsToRemove.map((food) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${food['name']} (${food['meal']})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${food['calories']} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  child: content,
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getRecommendations(int remainingCalories) {
    List<Map<String, dynamic>> suitableFoods = _foodLibrary
        .where((food) => food['calories'] <= remainingCalories)
        .toList();

    suitableFoods.sort((a, b) => b['calories'].compareTo(a['calories']));

    return suitableFoods.take(5).toList();
  }

  List<Map<String, dynamic>> _getFoodsToRemove(int excessCalories) {
    List<Map<String, dynamic>> allItems = [
      ..._breakfastItems.map((item) => {...item, 'meal': 'Breakfast'}),
      ..._lunchItems.map((item) => {...item, 'meal': 'Lunch'}),
      ..._dinnerItems.map((item) => {...item, 'meal': 'Dinner'}),
    ];

    allItems.sort((a, b) => b['calories'].compareTo(a['calories']));

    int currentExcess = excessCalories;
    List<Map<String, dynamic>> itemsToRemove = [];

    for (var item in allItems) {
      if (currentExcess <= 0) break;
      itemsToRemove.add(item);
      currentExcess -= item['calories'] as int;
    }

    return itemsToRemove;
  }

  Future<void> _loadFoodLibrary() async {
    _foodLibrary = [
      {'name': 'Nasi Lemak', 'description': 'coconut rice with sambal', 'calories': 398},
      {'name': 'Roti Canai', 'description': 'flatbread with curry', 'calories': 301},
      {'name': 'Char Kway Teow', 'description': 'stir-fried flat noodles', 'calories': 742},
      {'name': 'Satay', 'description': '5 sticks', 'calories': 306},
      {'name': 'Laksa', 'description': 'spicy noodle soup', 'calories': 432},
      // Add more food items as needed
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    int totalCalories = _breakfastCalories + _lunchCalories + _dinnerCalories;
    int remainingCalories = _goalCalories - totalCalories;

    return Scaffold(
      appBar: const MyAppbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Calorie",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Stack(
            children: [
              MyCustomCalendar(
                onDateChanged: _onDateChanged,
                initialDate: _selectedDate,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text("$totalCalories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Text("Taken", style: TextStyle(fontSize: 14, color: Colors.white70)),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 140,
                          width: 140,
                          child: CircularProgressIndicator(
                            value: (totalCalories / _goalCalories).clamp(0.0, 1.0),
                            strokeWidth: 20,
                            backgroundColor: Colors.grey,
                            color: totalCalories > _goalCalories ? Colors.red : Colors.green,
                          ),
                        ),
                        SizedBox(
                          height: 115,
                          width: 115,
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 20,
                            color: Colors.black,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("$_goalCalories", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 4),
                            Text("Goal", style: TextStyle(fontSize: 16, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 13.0),
                            child: Text(
                                remainingCalories >= 0 ? "$remainingCalories" : "0",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.only(right: 13.0),
                            child: Text(
                                remainingCalories >= 0 ? "Remaining" : "Exceeded",
                                style: TextStyle(fontSize: 14, color: Colors.white70)
                            ),
                          ),
                          if (remainingCalories < 0)
                            Padding(
                              padding: EdgeInsets.only(right: 13.0),
                              child: Text(
                                "by ${-remainingCalories}",
                                style: TextStyle(fontSize: 14, color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _showRecommendationPopup,
                      icon: Icon(
                        Icons.help_outline_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                      label: Text(
                        'Recommendations',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size(40, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MyDropdown(
                    title: "Breakfast",
                    subtitle: "$_breakfastCalories kcal",
                    selectedValue: _selectedBreakfast ?? '',
                    items: _breakfastItems.map((item) => {
                      'name': item['name'] as String,
                      'description': '${item['calories']} kcal, ${item['description']}',
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBreakfast = value;
                      });
                    },
                    onRemove: (itemName) => _removeFood('Breakfast', itemName),
                    onAdd: () => _addFood('Breakfast'),
                  ),
                  MyDropdown(
                    title: "Lunch",
                    subtitle: "$_lunchCalories kcal",
                    selectedValue: _selectedLunch ?? '',
                    items: _lunchItems.map((item) => {
                      'name': item['name'] as String,
                      'description': '${item['calories']} kcal, ${item['description']}',
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLunch = value;
                      });
                    },
                    onRemove: (itemName) => _removeFood('Lunch', itemName),
                    onAdd: () => _addFood('Lunch'),
                  ),
                  MyDropdown(
                    title: "Dinner",
                    subtitle: "$_dinnerCalories kcal",
                    selectedValue: _selectedDinner ?? '',
                    items: _dinnerItems.map((item) => {
                      'name': item['name'] as String,
                      'description': '${item['calories']} kcal, ${item['description']}',
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDinner = value;
                      });
                    },
                    onRemove: (itemName) => _removeFood('Dinner', itemName),
                    onAdd: () => _addFood('Dinner'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

