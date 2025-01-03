import 'package:flutter/material.dart';

class MyAddSetTemp extends StatefulWidget {
  final Map<String, dynamic> set;
  final bool isHistory;
  final Function(bool) onComplete;
  final Function(String, String) onUpdate;
  final VoidCallback onDelete;

  const MyAddSetTemp({
    Key? key,
    required this.set,
    required this.isHistory,
    required this.onComplete,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  _MyAddSetTempState createState() => _MyAddSetTempState();
}

class _MyAddSetTempState extends State<MyAddSetTemp> {
  bool _isCompleted = false;
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    // Format weight to show as integer if it's a whole number
    final weight = widget.set['weight'];
    final weightString = weight is double && weight % 1 == 0 ? weight.toInt().toString() : weight.toString();
    _weightController = TextEditingController(text: weightString);
    _repsController = TextEditingController(text: widget.set['reps'].toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          // Set column
          SizedBox(
            width: 60,
            child: Text(
              widget.isHistory ? 'History' : widget.set['set'].toString(),
              style: TextStyle(
                color: widget.isHistory ? Colors.grey : Colors.white,
                fontWeight: widget.isHistory ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          // Weight column
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: widget.isHistory
                  ? Text(
                widget.set['weight'].toString(),
                style: const TextStyle(color: Colors.grey),
              )
                  : TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'kg',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  widget.onUpdate('weight', value);
                },
              ),
            ),
          ),
          // Reps column
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: widget.isHistory
                  ? Text(
                widget.set['reps'].toString(),
                style: const TextStyle(color: Colors.grey),
              )
                  : TextField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'reps',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  widget.onUpdate('reps', value);
                },
              ),
            ),
          ),
          // Checkbox column
          if (!widget.isHistory)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCompleted = !_isCompleted;
                  widget.onComplete(_isCompleted);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isCompleted ? Colors.green : Colors.grey,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
          if (widget.isHistory)
            const SizedBox(width: 24), // Maintain spacing when checkbox is not shown
          // Delete button
          if (!widget.isHistory)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: widget.onDelete,
            ),
        ],
      ),
    );
  }
}

