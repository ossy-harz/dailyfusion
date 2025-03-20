// book/widgets/ai_recipe_generator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/recipe.dart';

class AIRecipeGenerator extends StatefulWidget {
  const AIRecipeGenerator({Key? key}) : super(key: key);

  @override
  _AIRecipeGeneratorState createState() => _AIRecipeGeneratorState();
}

class _AIRecipeGeneratorState extends State<AIRecipeGenerator> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _dietaryRestrictionsController = TextEditingController();
  final _specialEquipmentController = TextEditingController();

  String? _selectedRecipeType;
  Recipe? _generatedRecipe;
  bool _showRecipe = false;

  final List<String> _recipeTypes = [
    'Food',
    'Drink',
    'Juice/Smoothie',
    'Baked Goods',
    'Dessert',
    'Other'
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _ingredientsController.dispose();
    _cuisineController.dispose();
    _dietaryRestrictionsController.dispose();
    _specialEquipmentController.dispose();
    super.dispose();
  }

  Future<void> _generateRecipe() async {
    if (_formKey.currentState!.validate()) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      List<String>? ingredients;
      if (_ingredientsController.text.isNotEmpty) {
        ingredients = _ingredientsController.text
            .split(RegExp(r'[,;\n]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      // In the _generateRecipe method:
      final recipe = await bookProvider.generateRecipeWithAI(
        prompt: _promptController.text,
        recipeType: _selectedRecipeType,
        ingredients: ingredients,
        cuisine: _cuisineController.text,
        dietaryRestrictions: _dietaryRestrictionsController.text,
        specialEquipment: _specialEquipmentController.text,
      );

      if (recipe != null) {
        setState(() {
          _generatedRecipe = recipe;
          _showRecipe = true;
        });
      }
    }
  }

  void _saveRecipe() {
    if (_generatedRecipe != null) {
      Provider.of<BookProvider>(context, listen: false).addRecipe(_generatedRecipe!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('AI Recipe Generator'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (_showRecipe)
              TextButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.save),
                label: const Text('SAVE RECIPE'),
              ),
          ],
        ),
        body: _showRecipe
            ? _buildRecipePreview()
            : _buildGeneratorForm(bookProvider),
      ),
    );
  }

  Widget _buildGeneratorForm(BookProvider bookProvider) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAIBanner(),
            const SizedBox(height: 24),
            _buildMainPromptCard(),
            const SizedBox(height: 16),
            _buildOptionalDetailsCard(),
            const SizedBox(height: 24),
            _buildGenerateButton(bookProvider),
            if (bookProvider.error.isNotEmpty)
              _buildErrorText(bookProvider.error),
          ],
        ),
      ),
    );
  }

  Widget _buildAIBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade300,
            Colors.purple.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Text(
                'Gemini AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate custom recipes for any culinary creation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPromptCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe Foundation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRecipeType,
              items: _recipeTypes
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedRecipeType = value),
              decoration: const InputDecoration(
                labelText: 'Recipe Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null ? 'Please select a recipe type' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Describe your creation',
                hintText: 'e.g., Tropical mango smoothie, Vegan chocolate cake, '
                    'Espresso martini with vanilla twist',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please describe your recipe' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customization Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Ingredients (separate with commas)',
                hintText: 'e.g., fresh mango, coconut milk, chia seeds\n'
                    '2 cups ice, 1 shot espresso, vanilla syrup',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cuisineController,
              decoration: const InputDecoration(
                labelText: 'Cuisine/Flavor Profile',
                hintText: 'e.g., Tropical, Italian, Fusion',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dietaryRestrictionsController,
              decoration: const InputDecoration(
                labelText: 'Dietary Needs',
                hintText: 'e.g., Vegan, Gluten-free, Low-sugar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialEquipmentController,
              decoration: const InputDecoration(
                labelText: 'Special Equipment',
                hintText: 'e.g., Blender, Mixer, Sous-vide',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(BookProvider bookProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: bookProvider.isGeneratingRecipe ? null : _generateRecipe,
        icon: bookProvider.isGeneratingRecipe
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white),
        )
            : const Icon(Icons.auto_awesome),
        label: Text(
          bookProvider.isGeneratingRecipe
              ? 'Crafting Your Recipe...'
              : 'Generate Recipe',
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        error,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildRecipePreview() {
    if (_generatedRecipe == null) {
      return const Center(child: Text('No recipe generated'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecipeHeader(),
          const SizedBox(height: 16),
          _buildDescriptionCard(),
          const SizedBox(height: 16),
          _buildIngredientsCard(),
          const SizedBox(height: 16),
          _buildInstructionsCard(),
          const SizedBox(height: 32),
          _buildSaveButton(),
          const SizedBox(height: 16),
          _buildNewRecipeButton(),
        ],
      ),
    );
  }

  Widget _buildRecipeHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(_generatedRecipe!.imageUrl),
              fit: BoxFit.cover,
              onError: (_, __) {},
            ),
          ),
          child: _buildImageOverlay(),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: _buildAIGeneratedBadge(),
        ),
      ],
    );
  }

  Widget _buildImageOverlay() {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _generatedRecipe!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_generatedRecipe!.category != null)
                  Text(
                    _generatedRecipe!.category!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIGeneratedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'AI Generated',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipe Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(_generatedRecipe!.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(Icons.timer, 'Prep', '${_generatedRecipe!.prepTime} min'),
                _buildInfoItem(Icons.whatshot, 'Cook', '${_generatedRecipe!.cookTime} min'),
                _buildInfoItem(Icons.people, 'Serves', '${_generatedRecipe!.servings}'),
                if (_generatedRecipe!.temperature != null)
                  _buildInfoItem(Icons.thermostat, 'Temp', _generatedRecipe!.temperature!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._generatedRecipe!.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 12, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingredient)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._generatedRecipe!.steps.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _saveRecipe,
        icon: const Icon(Icons.save),
        label: const Text('Save Recipe'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildNewRecipeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => setState(() => _showRecipe = false),
        icon: const Icon(Icons.refresh),
        label: const Text('Create New Recipe'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}