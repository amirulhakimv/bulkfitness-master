import 'package:flutter/material.dart';

class MyAddDiscard extends StatelessWidget {
  final VoidCallback? onAddExercise;
  final VoidCallback? onDiscardWorkout;
  final VoidCallback? onRestTimerComplete;
  final bool isRestTimerRunning;

  const MyAddDiscard({
    Key? key,
    this.onAddExercise,
    this.onDiscardWorkout,
    this.onRestTimerComplete,
    required this.isRestTimerRunning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAddExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Add Exercise'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDiscardWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Discard Workout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

