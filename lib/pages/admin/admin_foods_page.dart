import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bulkfitness/components/my_appbar.dart';
import 'package:bulkfitness/components/my_text_field.dart';

class AdminFoodsPage extends StatefulWidget {
  const AdminFoodsPage({super.key});

  @override
  State<AdminFoodsPage> createState() => _AdminFoodsPageState();
}

class _AdminFoodsPageState extends State<AdminFoodsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _deleteFood(String foodId) async {
    try {
      await FirebaseFirestore.instance.collection('custom_foods').doc(foodId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting food: $e')),
      );
    }
  }

  Future<void> _editFood(String foodId, String currentName, String currentDescription, int currentCalories) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController descriptionController = TextEditingController(text: currentDescription);
    TextEditingController caloriesController = TextEditingController(text: currentCalories.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Edit Food', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Food Name',
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
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: caloriesController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Calories',
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
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Food Description',
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
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save', style: TextStyle(color: Colors.blue)),
            onPressed: () async {
              int? calories = int.tryParse(caloriesController.text);
              if (calories == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number for calories')),
                );
                return;
              }
              await FirebaseFirestore.instance.collection('custom_foods').doc(foodId).update({
                'name': nameController.text,
                'description': descriptionController.text,
                'calories': calories,
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(
        showBackButton: true,
      ),
      body: Column(
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
                  hintText: 'Search foods',
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
              stream: FirebaseFirestore.instance.collection('custom_foods').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No foods found.'));
                }

                final foods = snapshot.data!.docs
                    .where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['name'].toString().toLowerCase().contains(_searchQuery) ||
                      data['description'].toString().toLowerCase().contains(_searchQuery);
                })
                    .toList();

                foods.sort((a, b) {
                  final nameA = (a.data() as Map<String, dynamic>)['name'].toString().toLowerCase();
                  final nameB = (b.data() as Map<String, dynamic>)['name'].toString().toLowerCase();
                  return nameA.compareTo(nameB);
                });

                return ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final doc = foods[index];
                    final food = doc.data() as Map<String, dynamic>;
                    final foodId = doc.id;

                    return ListTile(
                      title: Text(
                        food['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calories: ${food['calories']}',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            food['description'],
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      leading: const Icon(
                        Icons.fastfood,
                        color: Colors.white,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editFood(foodId, food['name'], food['description'], food['calories']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFood(foodId),
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
