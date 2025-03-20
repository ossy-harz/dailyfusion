
class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final int prepTime;
  final int cookTime;
  final int servings;
  final List<String> categories;
  final bool isFavorite;
  final DateTime dateAdded;
  final String? category;       // New field
  final String? temperature;    // New field
  final List<String> equipment; // New field
  static const String defaultImage = 'assets/images/recipe_placeholder.jpg';


  String get displayImage {
    return imageUrl.isEmpty ? defaultImage : imageUrl;
  }
  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.categories,
    required this.isFavorite,
    required this.dateAdded,
    this.category,
    this.temperature,
    this.equipment = const [], // Initialize with empty list
  });

  // Update copyWith
  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? steps,
    int? prepTime,
    int? cookTime,
    int? servings,
    List<String>? categories,
    bool? isFavorite,
    DateTime? dateAdded,
    String? category,
    String? temperature,
    List<String>? equipment,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      categories: categories ?? this.categories,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded ?? this.dateAdded,
      category: category ?? this.category,
      temperature: temperature ?? this.temperature,
      equipment: equipment ?? this.equipment,
    );
  }

  // Update toJson
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'categories': categories,
      'isFavorite': isFavorite,
      'dateAdded': dateAdded.toIso8601String(),
      'category': category,
      'temperature': temperature,
      'equipment': equipment,
    };
  }

  // Update fromJson
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      prepTime: json['prepTime'] ?? 0,
      cookTime: json['cookTime'] ?? 0,
      servings: json['servings'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      category: json['category'],
      temperature: json['temperature'],
      equipment: List<String>.from(json['equipment'] ?? []),
    );
  }
}