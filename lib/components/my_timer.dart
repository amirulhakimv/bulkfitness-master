import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalTimer {
  static final Map<String, GlobalTimer> _instances = {};
  static GlobalTimer getInstance(String userId) {
    if (!_instances.containsKey(userId)) {
      _instances[userId] = GlobalTimer._internal();
    }
    return _instances[userId]!;
  }

  GlobalTimer._internal();

  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  final List<Function(int)> _listeners = [];

  int get seconds => _seconds;
  bool get isRunning => _isRunning;

  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _seconds++;
        _notifyListeners();
      });
    }
  }

  void stopTimer() {
    _isRunning = false;
    _timer?.cancel();
    _notifyListeners();
  }

  void resetTimer() {
    _seconds = 0;
    _isRunning = false;
    _timer?.cancel();
    _notifyListeners();
  }

  int getCurrentTime() {
    return _seconds;
  }

  void addListener(Function(int) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(int) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_seconds);
    }
  }
}

class MyTimer extends StatefulWidget {
  final int initialSeconds;
  final bool isWorkoutTimer;
  final VoidCallback? onComplete;
  final bool isRunning;
  final VoidCallback? onFinish;

  const MyTimer({
    Key? key,
    required this.initialSeconds,
    this.isWorkoutTimer = false,
    this.onComplete,
    this.isRunning = false,
    this.onFinish,
  }) : super(key: key);

  @override
  _MyTimerState createState() => _MyTimerState();
}

class _MyTimerState extends State<MyTimer> {
  late GlobalTimer _globalTimer;
  late int _seconds;
  late bool _isRunning;
  Timer? _timer;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _globalTimer = GlobalTimer.getInstance(_userId ?? '');
    _seconds = widget.isWorkoutTimer ? _globalTimer.getCurrentTime() : widget.initialSeconds;
    _isRunning = widget.isWorkoutTimer ? _globalTimer.isRunning : widget.isRunning;

    if (widget.isWorkoutTimer) {
      _globalTimer.addListener(_updateTimer);
      if (!_globalTimer.isRunning) {
        _globalTimer.startTimer();
      }
    }
  }

  @override
  void dispose() {
    if (widget.isWorkoutTimer) {
      _globalTimer.removeListener(_updateTimer);
    }
    _timer?.cancel();
    super.dispose();
  }

  void _updateTimer(int seconds) {
    if (mounted) {
      setState(() {
        _seconds = seconds;
        _isRunning = _globalTimer.isRunning;
      });
    }
  }

  void _startTimer() {
    if (widget.isWorkoutTimer) {
      _globalTimer.startTimer();
    } else {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _stopTimer();
            widget.onComplete?.call();
          }
        });
      });
    }
  }

  void _stopTimer() {
    if (widget.isWorkoutTimer) {
      _globalTimer.stopTimer();
    } else {
      setState(() {
        _isRunning = false;
      });
      _timer?.cancel();
    }
  }

  void _resetTimer() {
    if (widget.isWorkoutTimer) {
      _globalTimer.resetTimer();
    } else {
      setState(() {
        _seconds = widget.initialSeconds;
        _isRunning = false;
      });
      _timer?.cancel();
    }
  }

  void _showTimerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: ListView.builder(
            itemCount: 21,
            itemBuilder: (context, index) {
              int minutes = (index * 15) ~/ 60;
              int seconds = (index * 15) % 60;
              return ListTile(
                title: Text('$minutes:${seconds.toString().padLeft(2, '0')}'),
                onTap: () {
                  setState(() {
                    _seconds = minutes * 60 + seconds;
                    Navigator.pop(context);
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showFinishConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Finish Workout'),
          content: Text('Are you sure you want to finish your workout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
                _finishWorkout();
              },
            ),
          ],
        );
      },
    );
  }

  void _finishWorkout() {
    _globalTimer.stopTimer();
    print('Workout finished. Duration: ${_formatTime(_seconds)}');
    widget.onFinish?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.isWorkoutTimer ? null : _showTimerOptions,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    _formatTime(_seconds),
                    style: TextStyle(
                      color: widget.isWorkoutTimer ? Colors.white : (_isRunning ? Colors.red : Colors.white),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (widget.isWorkoutTimer)
                IconButton(
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                ),
              if (!widget.isWorkoutTimer) ...[
                IconButton(
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  color: Colors.white,
                  onPressed: () {
                    _resetTimer();
                    widget.onComplete?.call();
                  },
                ),
              ],
            ],
          ),
          if (widget.isWorkoutTimer)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: _showFinishConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Finish'),
              ),
            ),
        ],
      ),
    );
  }
}

