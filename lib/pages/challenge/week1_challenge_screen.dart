import 'dart:async';

import 'package:bulkfitness/components/customText.dart';
import 'package:bulkfitness/components/workout_widget.dart';
import 'package:bulkfitness/utils/constants.dart';
import 'package:flutter/material.dart';

class Week1ChallengeScreen extends StatefulWidget {
  const Week1ChallengeScreen({super.key});

  @override
  State<Week1ChallengeScreen> createState() => _Week1ChallengeScreenState();
}

class _Week1ChallengeScreenState extends State<Week1ChallengeScreen> {
  Timer? _timer;
  Duration _remainingTime = Duration(minutes: 30); // Set initial time here
  bool _isRunning = false;
  bool _isPaused = false;

  void _startTimer() {
    if (_isRunning) return; // Prevent starting if already running

    _timer?.cancel();
    _isRunning = true;
    _isPaused = false;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    if (_isRunning || _remainingTime.inSeconds <= 0) return; // Prevent resuming if already running or time is finished

    _isRunning = true;
    _isPaused = false;
    _startTimer();
  }

  String get timerText {
    String minutes = _remainingTime.inMinutes.toString().padLeft(2, '0');
    String seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(responsive(16, context)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: responsive(18, context)),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CustomText(
                    text: 'Workout Challenge',
                    color: Colors.white,
                    fontSize: responsive(18, context),
                    weight: FontWeight.w500,
                  ),
                ),
              ),

              /// 2nd Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: responsive(15, context), vertical: responsive(20, context)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(responsive(12, context)),
                  color: Colors.white10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Full Body Strength',
                              color: Colors.white,
                              fontSize: responsive(14, context),
                              weight: FontWeight.w500,
                            ),
                            CustomText(
                              text: '$timerText . 5 exercises',
                              color: Colors.grey,
                              fontSize: responsive(13, context),
                              weight: FontWeight.w400,
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (!_isRunning) {
                              _startTimer(); // Start the countdown
                            } else if (_isPaused) {
                              _resumeTimer(); // Resume the countdown
                            } else {
                              _stopTimer(); // Stop the countdown
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: responsive(15, context), vertical: responsive(8, context)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(responsive(8, context)),
                              color: Colors.white24,
                            ),
                            child: CustomText(
                              text: !_isRunning
                                  ? 'Start'
                                  : _isPaused
                                      ? 'Resume'
                                      : 'Stop',
                              color: Colors.white,
                              fontSize: responsive(15, context),
                              weight: FontWeight.w400,
                            ),
                          ),
                        )
                      ],
                    ),
                    const WorkoutWidget(title: 'Push-ups', subTitle: '3 sets . 8-10 reps', image: 'lib/images/push_ups.png'),
                    const WorkoutWidget(title: 'Squats', subTitle: '3 sets . 12-15 reps', image: 'lib/images/squats.png'),
                    const WorkoutWidget(title: 'Planks', subTitle: '3 sets . 20-30 seconds reps', image: 'lib/images/planks.png'),
                    const WorkoutWidget(title: 'Dumbbell Rows', subTitle: '3 sets . 10 reps', image: 'lib/images/dumble_row.png'),
                    const WorkoutWidget(title: 'Lunges', subTitle: '3 sets . 10 per leg reps', image: 'lib/images/lungs.png'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
