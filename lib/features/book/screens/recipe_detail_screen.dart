import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/book_provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    final recipe = await Provider.of<BookProvider>(context, listen: false)
        .getRecipeById(widget.recipeId);
    setState(() {
      _recipe = recipe;
      _isLoading = false;
    });
  }

  void _showEditDialog() {
    if (_recipe == null) return;

    showDialog(
      context: context,
      builder: (ctx) => RecipeEditDialog(
        recipe: _recipe!,
        onSave: (updatedRecipe) async {
          await Provider.of<BookProvider>(context, listen: false)
              .updateRecipe(updatedRecipe);
          _loadRecipe();
        },
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<BookProvider>(context, listen: false)
                  .deleteRecipe(widget.recipeId);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recipe == null) {
      return Scaffold(
        body: Center(child: Text('Recipe not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showEditDialog,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _confirmDelete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_recipe!.title),
              background: _RecipeImageHeader(recipe: _recipe!),
            ),
          ),
          SliverToBoxAdapter(
            child: _RecipeContent(recipe: _recipe!),
          ),
        ],
      ),
    );
  }
}

class _RecipeImageHeader extends StatelessWidget {
  final Recipe recipe;

  const _RecipeImageHeader({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        recipe.imageUrl.isEmpty
            ? Container(
          color: Colors.grey[200],
          child: Center(
            child: Icon(
              Icons.restaurant_menu,
              size: 100,
              color: Colors.grey[400],
            ),
          ),
        )
            : Image.network(
          recipe.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (ctx, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.broken_image,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeContent extends StatelessWidget {
  final Recipe recipe;

  const _RecipeContent({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecipeMetaInfo(recipe: recipe),
          const SizedBox(height: 24),
          _RecipeSection(
            title: 'Description',
            child: Text(
              recipe.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          _RecipeSection(
            title: 'Ingredients',
            child: Column(
              children: recipe.ingredients
                  .map((ingredient) => _IngredientItem(ingredient: ingredient))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          _RecipeSection(
            title: 'Steps',
            child: Column(
              children: recipe.steps
                  .asMap()
                  .entries
                  .map((entry) => _StepItem(index: entry.key, step: entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeMetaInfo extends StatelessWidget {
  final Recipe recipe;

  const _RecipeMetaInfo({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MetaInfoItem(
          icon: Icons.timer,
          label: 'Prep',
          value: '${recipe.prepTime} min',
        ),
        _MetaInfoItem(
          icon: Icons.whatshot,
          label: 'Cook',
          value: '${recipe.cookTime} min',
        ),
        _MetaInfoItem(
          icon: Icons.people,
          label: 'Serves',
          value: '${recipe.servings}',
        ),
      ],
    );
  }
}

class _MetaInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}

class _RecipeSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _RecipeSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Divider(),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final String ingredient;

  const _IngredientItem({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(ingredient)),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String step;

  const _StepItem({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(step, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class RecipeEditDialog extends StatefulWidget {
  final Recipe recipe;
  final Function(Recipe) onSave;

  const RecipeEditDialog({
    required this.recipe,
    required this.onSave,
  });

  @override
  _RecipeEditDialogState createState() => _RecipeEditDialogState();
}

class _RecipeEditDialogState extends State<RecipeEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(text: widget.recipe.description);
    _imageUrlController = TextEditingController(text: widget.recipe.imageUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Recipe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedRecipe = widget.recipe.copyWith(
              title: _titleController.text,
              description: _descriptionController.text,
              imageUrl: _imageUrlController.text,
            );
            widget.onSave(updatedRecipe);
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}