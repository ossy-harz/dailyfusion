import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/workout.dart';

class FitnessProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  List<Workout> _workouts = [];
  List<Workout> _completedWorkouts = [];
  DateTime _selectedDate = DateTime.now();
  
  List<Workout> get workouts => _workouts;
  List<Workout> get completedWorkouts => _completedWorkouts;
  DateTime get selectedDate => _selectedDate;
  
  // Get workouts for the selected date
  List<Workout> get workoutsForSelectedDate {
    // In a real app, this would filter workouts by date
    return _workouts;
  }
  
  // Get recommended workouts based on user preferences and history
  List<Workout> get recommendedWorkouts {
    // In a real app, this would use an algorithm to recommend workouts
    return _workouts.take(3).toList();
  }
  
  FitnessProvider() {
    _loadWorkouts();
  }
  
  Future<void> _loadWorkouts() async {
    try {
      final data = await _storageService.getCollection('workouts');
      _workouts = data.map((json) => Workout.fromJson(json)).toList();
      _completedWorkouts = _workouts.where((workout) => workout.isCompleted).toList();
      
      // If no workouts exist, add sample workouts
      if (_workouts.isEmpty) {
        _addSampleWorkouts();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      _addSampleWorkouts();
    }
  }
  
  void _addSampleWorkouts() {
    _workouts = [
      Workout(
        id: '1',
        title: 'Morning HIIT',
        description: 'High-intensity interval training to start your day',
        type: WorkoutType.hiit,
        difficulty: WorkoutDifficulty.intermediate,
        durationMinutes: 30,
        caloriesBurned: 300,
        exercises: [
          Exercise(
            id: '1',
            name: 'Jumping Jacks',
            description: 'Full body exercise',
            sets: 3,
            reps: 20,
            durationSeconds: 60,
          ),
          Exercise(
            id: '2',
            name: 'Push-ups',
            description: 'Upper body strength',
            sets: 3,
            reps: 15,
          ),
          Exercise(
            id: '3',
            name: 'Burpees',
            description: 'Full body exercise',
            sets: 3,
            reps: 10,
            durationSeconds: 60,
          ),
        ],
      ),
      Workout(
        id: '2',
        title: 'Yoga Flow',
        description: 'Relaxing yoga session for flexibility and mindfulness',
        type: WorkoutType.yoga,
        difficulty: WorkoutDifficulty.beginner,
        durationMinutes: 45,
        caloriesBurned: 150,
        exercises: [
          Exercise(
            id: '1',
            name: 'Sun Salutation',
            description: 'Warm-up sequence',
            sets: 1,
            reps: 5,
            durationSeconds: 300,
          ),
          Exercise(
            id: '2',
            name: 'Warrior Poses',
            description: 'Standing poses for strength',
            sets: 1,
            reps: 3,
            durationSeconds: 180,
          ),
        ],
      ),
      Workout(
        id: '3',
        title: 'Strength Training',
        description: 'Full body strength workout with weights',
        type: WorkoutType.strength,
        difficulty: WorkoutDifficulty.advanced,
        durationMinutes: 60,
        caloriesBurned: 400,
        exercises: [
          Exercise(
            id: '1',
            name: 'Squats',
            description: 'Lower body strength',
            sets: 4,
            reps: 12,
            weightKg: 30,
          ),
          Exercise(
            id: '2',
            name: 'Bench Press',
            description: 'Chest and arms',
            sets: 4,
            reps: 10,
            weightKg: 40,
          ),
          Exercise(
            id: '3',
            name: 'Deadlifts',
            description: 'Back and legs',
            sets: 4,
            reps: 8,
            weightKg: 50,
          ),
        ],
      ),
    ];
    
    notifyListeners();
  }
  
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  Future<void> addWorkout(Workout workout) async {
    _workouts.add(workout);
    await _storageService.addDocument('workouts', workout.toJson());
    notifyListeners();
  }
  
  Future<void> updateWorkout(Workout workout) async {
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
      await _storageService.updateDocument('workouts', workout.id, workout.toJson());
      
      // Update completed workouts if necessary
      if (workout.isCompleted) {
        _completedWorkouts.add(workout);
      } else {
        _completedWorkouts.removeWhere((w) => w.id == workout.id);
      }
      
      notifyListeners();
    }
  }
  
  Future<void> deleteWorkout(String id) async {
    _workouts.removeWhere((workout) => workout.id == id);
    _completedWorkouts.removeWhere((workout) => workout.id == id);
    await _storageService.deleteDocument('workouts', id);
    notifyListeners();
  }
  
  Future<void> completeWorkout(String id) async {
    final index = _workouts.indexWhere((workout) => workout.id == id);
    if (index != -1) {
      final workout = _workouts[index].copyWith(isCompleted: true);
      _workouts[index] = workout;
      _completedWorkouts.add(workout);
      await _storageService.updateDocument('workouts', id, workout.toJson());
      notifyListeners();
    }
  }
}

