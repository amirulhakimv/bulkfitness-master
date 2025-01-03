import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bulkfitness/components/my_appbar.dart';

class AdminFoodsPage extends StatefulWidget {
  const AdminFoodsPage({super.key});

  @override
  State<AdminFoodsPage> createState() => _AdminFoodsPageState();
}

class _AdminFoodsPageState extends State<AdminFoodsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Method to delete a food item by its document ID
  Future<void> _deleteFood(String foodId) async {
    try {
      // Delete the food item by document ID
      await FirebaseFirestore.instance.collection('custom_foods').doc(foodId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food item deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting food: $e')));
    }
  }

  // Method to edit food details
  Future<void> _editFood(String foodId, String currentName, String currentDescription) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController descriptionController = TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Food'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Food Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Food Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update the food document in Firestore
                await FirebaseFirestore.instance.collection('custom_foods').doc(foodId).update({
                  'name': nameController.text,
                  'description': descriptionController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(showBackButton: true),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search foods...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
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
                    final foodId = doc.id;  // Get the document ID

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey[850],
                      child: ListTile(
                        title: Text(
                          food['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          food['description'],
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Call _editFood method for editing
                                _editFood(foodId, food['name'], food['description']);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFood(foodId),  // Pass the foodId to delete
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
