import 'package:flutter/material.dart';

class MyCustomCalendar extends StatefulWidget {
  final Function(DateTime) onDateChanged;
  final DateTime initialDate;

  const MyCustomCalendar({
    Key? key,
    required this.onDateChanged,
    required this.initialDate,
  }) : super(key: key);

  @override
  _MyCustomCalendarState createState() => _MyCustomCalendarState();
}

class _MyCustomCalendarState extends State<MyCustomCalendar> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      widget.onDateChanged(_selectedDate);
    });
  }

  Widget _getDateText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final selectedDateOnly = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day
    );

    String dayLabel = '';
    if (selectedDateOnly.isAtSameMomentAs(today)) {
      dayLabel = 'Today';
    } else if (selectedDateOnly.isAtSameMomentAs(yesterday)) {
      dayLabel = 'Yesterday';
    } else if (selectedDateOnly.isAtSameMomentAs(tomorrow)) {
      dayLabel = 'Tomorrow';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dayLabel.isNotEmpty)
          Text(
            dayLabel,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.2,
            ),
          ),
        Text(
          _formatDate(_selectedDate),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _changeDate(-1),
          color: Colors.white,
        ),
        _getDateText(),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => _changeDate(1),
          color: Colors.white,
        ),
      ],
    );
  }
}