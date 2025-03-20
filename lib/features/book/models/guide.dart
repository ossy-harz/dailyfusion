class Guide {
  final String id;
  final String title;
  final String description;
  final List<Map<String, String>> sections;
  final String imageUrl;
  final List<String> categories;
  final bool isFavorite;
  final DateTime dateAdded;

  Guide({
    required this.id,
    required this.title,
    required this.description,
    required this.sections,
    required this.imageUrl,
    required this.categories,
    required this.isFavorite,
    required this.dateAdded,
  });

  // Create a copy of the guide with updated fields
  Guide copyWith({
    String? id,
    String? title,
    String? description,
    List<Map<String, String>>? sections,
    String? imageUrl,
    List<String>? categories,
    bool? isFavorite,
    DateTime? dateAdded,
  }) {
    return Guide(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sections: sections ?? this.sections,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  // Convert Guide to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'sections': sections,
      'imageUrl': imageUrl,
      'categories': categories,
      'isFavorite': isFavorite,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  // Create Guide from Firestore JSON
  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sections: (json['sections'] as List<dynamic>?)?.map((section) => section as Map<String, String>)?.toList() ?? [],
      imageUrl: json['imageUrl'] ?? '',
      categories: (json['categories'] as List<dynamic>?)?.map((category) => category as String)?.toList() ?? [],
      isFavorite: json['isFavorite'] ?? false,
      dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
    );
  }
}
