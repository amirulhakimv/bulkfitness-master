import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/my_appbar.dart';
import '../../components/my_button.dart';
import '../../components/my_text_field.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({Key? key}) : super(key: key);

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addFood() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new document reference in the 'custom_foods' collection
        DocumentReference docRef =
        FirebaseFirestore.instance.collection('custom_foods').doc();

        // Prepare the food data
        Map<String, dynamic> foodData = {
          'id': docRef.id, // Use the document ID as the food ID
          'name': _nameController.text.trim(),
          'calories': int.parse(_caloriesController.text.trim()),
          'description': _descriptionController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Set the data for the new document
        await docRef.set(foodData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food added successfully')),
        );

        // Clear the fields after adding food
        _nameController.clear();
        _caloriesController.clear();
        _descriptionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding food: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MyAppbar(
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Food',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _nameController,
                  hintText: 'Food Name',
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a food name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _caloriesController,
                  hintText: 'Calories',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the calorie count';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyButton(
                  onTap: _addFood,
                  text: 'Add Food',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
