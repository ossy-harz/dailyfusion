import 'package:flutter/material.dart';
import '../models/timeline_event.dart';

class DashboardProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  
  DateTime get selectedDate => _selectedDate;
  
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  // Sample timeline events
  List<TimelineEvent> get timelineEvents {
    return [
      TimelineEvent(
        id: '1',
        title: 'Morning Workout',
        description: 'HIIT Training - 30 minutes',
        time: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 7, 0),
        type: EventType.fitness,
        progress: 1.0,
      ),
      TimelineEvent(
        id: '2',
        title: 'Team Meeting',
        description: 'Weekly sync with the product team',
        time: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 9, 30),
        type: EventType.task,
      ),
      TimelineEvent(
        id: '3',
        title: 'Lunch',
        description: 'Try new recipe: Quinoa Salad',
        time: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 12, 0),
        type: EventType.book,
      ),
      TimelineEvent(
        id: '4',
        title: 'Coffee Purchase',
        description: '\$4.50 - Daily budget for coffee',
        time: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 15, 0),
        type: EventType.budget,
      ),
      TimelineEvent(
        id: '5',
        title: 'Evening Yoga',
        description: 'Relaxation session - 20 minutes',
        time: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 18, 0),
        type: EventType.fitness,
        progress: 0.0,
      ),
      TimelineEvent(
        id: '6',
        title: 'Journal Entry',
        description: 'Reflect on today\'s achievements',
        time: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 21, 0),
        type: EventType.journal,
      ),
    ];
  }
}

