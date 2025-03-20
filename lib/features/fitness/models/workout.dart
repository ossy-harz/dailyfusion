enum WorkoutType {
  cardio,
  strength,
  flexibility,
  hiit,
  yoga,
  custom
}

enum WorkoutDifficulty {
  beginner,
  intermediate,
  advanced
}

class Workout {
  final String id;
  final String title;
  final String description;
  final WorkoutType type;
  final WorkoutDifficulty difficulty;
  final int durationMinutes;
  final int caloriesBurned;
  final List<Exercise> exercises;
  final String? imageUrl;
  final bool isCompleted;
  
  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.exercises,
    this.imageUrl,
    this.isCompleted = false,
  });
  
  Workout copyWith({
    String? id,
    String? title,
    String? description,
    WorkoutType? type,
    WorkoutDifficulty? difficulty,
    int? durationMinutes,
    int? caloriesBurned,
    List<Exercise>? exercises,
    String? imageUrl,
    bool? isCompleted,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      exercises: exercises ?? this.exercises,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'difficulty': difficulty.toString(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
    };
  }
  
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: WorkoutType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => WorkoutType.custom,
      ),
      difficulty: WorkoutDifficulty.values.firstWhere(
        (e) => e.toString() == json['difficulty'],
        orElse: () => WorkoutDifficulty.intermediate,
      ),
      durationMinutes: json['durationMinutes'],
      caloriesBurned: json['caloriesBurned'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      imageUrl: json['imageUrl'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int sets;
  final int reps;
  final int? weightKg;
  final int? durationSeconds;
  
  Exercise({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.durationSeconds,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sets': sets,
      'reps': reps,
      'weightKg': weightKg,
      'durationSeconds': durationSeconds,
    };
  }
  
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      sets: json['sets'],
      reps: json['reps'],
      weightKg: json['weightKg'],
      durationSeconds: json['durationSeconds'],
    );
  }
}

