import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../models/guide.dart';
import '../models/recipe.dart';
import '../models/pantry_item.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _recipesCollection = 'recipes';
  static const String _guidesCollection = 'guides';
  static const String _pantryCollection = 'pantry';

  // State variables
  List<Recipe> _recipes = [];
  List<Guide> _guides = [];
  List<PantryItem> _pantryItems = [];
  bool _isLoading = false;
  bool _isGeneratingRecipe = false;
  String _error = '';

  // Getters
  List<Recipe> get recipes => [..._recipes];
  List<Guide> get guides => [..._guides];
  List<PantryItem> get pantryItems => [..._pantryItems];
  bool get isLoading => _isLoading;
  bool get isGeneratingRecipe => _isGeneratingRecipe;
  String get error => _error;

  // Initialize data
  Future<void> initData() async {
    try {
      await Future.wait([
        fetchRecipes(),
        fetchGuides(),
        fetchPantryItems(),
      ]);
    } catch (e) {
      _setError('Failed to initialize data: $e');
    }
  }

  // RECIPE CRUD OPERATIONS

  // Fetch all recipes
  Future<void> fetchRecipes() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore.collection(_recipesCollection).get();
      _recipes = snapshot.docs
          .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to fetch recipes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final doc = await _firestore.collection(_recipesCollection).doc(id).get();
      if (doc.exists) {
        return Recipe.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      _setError('Failed to get recipe: $e');
      return null;
    }
  }

  // Add a new recipe
  Future<void> addRecipe(Recipe recipe) async {
    _setLoading(true);
    try {
      final docRef = await _firestore.collection(_recipesCollection).add(recipe.toJson());
      final newRecipe = recipe.copyWith(id: docRef.id);
      _recipes.add(newRecipe);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to add recipe: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing recipe
  Future<void> updateRecipe(Recipe recipe) async {
    _setLoading(true);
    try {
      await _firestore.collection(_recipesCollection).doc(recipe.id).update(recipe.toJson());
      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index >= 0) {
        _recipes[index] = recipe;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      _setError('Failed to update recipe: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String id) async {
    _setLoading(true);
    try {
      await _firestore.collection(_recipesCollection).doc(id).delete();
      _recipes.removeWhere((recipe) => recipe.id == id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to delete recipe: $e');
    } finally {
      _setLoading(false);
    }
  }

  // GUIDE CRUD OPERATIONS

  // Fetch all guides
  Future<void> fetchGuides() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore.collection(_guidesCollection).get();
      _guides = snapshot.docs
          .map((doc) => Guide.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to fetch guides: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get guide by ID
  Future<Guide?> getGuideById(String id) async {
    try {
      final doc = await _firestore.collection(_guidesCollection).doc(id).get();
      if (doc.exists) {
        return Guide.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      _setError('Failed to get guide: $e');
      return null;
    }
  }

  // Add a new guide
  Future<void> addGuide(Guide guide) async {
    _setLoading(true);
    try {
      final docRef = await _firestore.collection(_guidesCollection).add(guide.toJson());
      final newGuide = guide.copyWith(id: docRef.id);
      _guides.add(newGuide);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to add guide: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing guide
  Future<void> updateGuide(Guide guide) async {
    _setLoading(true);
    try {
      await _firestore.collection(_guidesCollection).doc(guide.id).update(guide.toJson());
      final index = _guides.indexWhere((g) => g.id == guide.id);
      if (index >= 0) {
        _guides[index] = guide;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      _setError('Failed to update guide: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a guide
  Future<void> deleteGuide(String id) async {
    _setLoading(true);
    try {
      await _firestore.collection(_guidesCollection).doc(id).delete();
      _guides.removeWhere((guide) => guide.id == id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to delete guide: $e');
    } finally {
      _setLoading(false);
    }
  }

  // PANTRY CRUD OPERATIONS

  // Fetch all pantry items
  Future<void> fetchPantryItems() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore.collection(_pantryCollection).get();
      _pantryItems = snapshot.docs
          .map((doc) => PantryItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to fetch pantry items: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new pantry item
  Future<void> addPantryItem(PantryItem item) async {
    _setLoading(true);
    try {
      final docRef = await _firestore.collection(_pantryCollection).add(item.toJson());
      final newItem = item.copyWith(id: docRef.id);
      _pantryItems.add(newItem);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to add pantry item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing pantry item
  Future<void> updatePantryItem(PantryItem item) async {
    _setLoading(true);
    try {
      await _firestore.collection(_pantryCollection).doc(item.id).update(item.toJson());
      final index = _pantryItems.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _pantryItems[index] = item;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      _setError('Failed to update pantry item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a pantry item
  Future<void> deletePantryItem(String id) async {
    _setLoading(true);
    try {
      await _firestore.collection(_pantryCollection).doc(id).delete();
      _pantryItems.removeWhere((item) => item.id == id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to delete pantry item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // AI RECIPE GENERATION

  // Generate a recipe using Gemini AI
  Future<Recipe?> generateRecipeWithAI({
    required String prompt,
    required String? recipeType,
    List<String>? ingredients,
    String? cuisine,
    String? dietaryRestrictions,
    String? specialEquipment,
  }) async {
    _isGeneratingRecipe = true;
    notifyListeners();

    try {
      final apiKey = 'AIzaSyA3kMSr0AiqnDc_m6UJJKwdav9USXQbSrA';
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );

      String fullPrompt = 'Generate a detailed $recipeType recipe for $prompt.';

      if (ingredients != null && ingredients.isNotEmpty) {
        fullPrompt += ' Use these ingredients: ${ingredients.join(', ')}.';
      }

      if (cuisine != null && cuisine.isNotEmpty) {
        fullPrompt += ' Cuisine style: $cuisine.';
      }

      if (dietaryRestrictions != null && dietaryRestrictions.isNotEmpty) {
        fullPrompt += ' Dietary restrictions: $dietaryRestrictions.';
      }

      if (specialEquipment != null && specialEquipment.isNotEmpty) {
        fullPrompt += ' Required equipment: $specialEquipment.';
      }

      fullPrompt += '''
    Format the response as a JSON object with these fields: 
    - title (string)
    - description (string)
    - ingredients (array of strings)
    - steps (array of strings)
    - prepTime (number in minutes)
    - cookTime (number in minutes)
    - servings (number)
    - categories (array of strings)
    - isFavorite (boolean)
    - imageUrl (string)
    - dateAdded (ISO 8601 date string)
    - category (string)
    - temperature (string if applicable)
    - equipment (array of strings)
    
    Include measurements in ingredients. 
    Add numbered steps with clear instructions.
    ''';

      final content = [Content.text(fullPrompt)];
      final response = await model.generateContent(content);

      String jsonStr = _extractJson(response.text ?? '');
      final Map<String, dynamic> recipeJson = jsonDecode(jsonStr);

      return Recipe(
        id: '',
        title: recipeJson['title'] ?? prompt,
        description: recipeJson['description'] ?? '',
        imageUrl: recipeJson['imageUrl'] ?? 'https://via.placeholder.com/400x300?text=Recipe',
        ingredients: List<String>.from(recipeJson['ingredients'] ?? []),
        steps: List<String>.from(recipeJson['steps'] ?? []),
        prepTime: recipeJson['prepTime'] ?? 0,
        cookTime: recipeJson['cookTime'] ?? 0,
        servings: recipeJson['servings'] ?? 2,
        categories: List<String>.from(recipeJson['categories'] ?? []),
        isFavorite: recipeJson['isFavorite'] ?? false,
        dateAdded: DateTime.now(),
        category: recipeJson['category'],
        temperature: recipeJson['temperature'],
        equipment: List<String>.from(recipeJson['equipment'] ?? []),
      );
    } catch (e) {
      _setError('Failed to generate recipe: $e');
      return null;
    } finally {
      _isGeneratingRecipe = false;
      notifyListeners();
    }
  }

  String _extractJson(String response) {
    final startIndex = response.indexOf('{');
    final endIndex = response.lastIndexOf('}') + 1;
    return response.substring(startIndex, endIndex);
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String message) {
    _error = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void clearError() {
    _error = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
