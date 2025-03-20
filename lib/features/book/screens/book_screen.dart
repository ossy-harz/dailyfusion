import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/guide.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart'; // Ensure your Recipe model is imported
import '../providers/book_provider.dart';
import '../widgets/recipe_grid.dart';
import '../widgets/guide_list.dart';
import '../widgets/pantry_list.dart';
import '../widgets/ai_recipe_generator.dart';
import '../screens/add_recipe_screen.dart';
import '../screens/add_guide_screen.dart';
import '../screens/add_pantry_item_screen.dart';
import '../screens/recipe_detail_screen.dart'; // Import your recipe details screen

class BookScreen extends StatefulWidget {
  const BookScreen({Key? key}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab index changes
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<BookProvider>(context, listen: false).initData().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToAddRecipe() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddRecipeScreen(),
      ),
    );
  }

  void _navigateToAddGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddGuideScreen(),
      ),
    );
  }

  void _navigateToAddPantryItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddPantryItemScreen(),
      ),
    );
  }

  void _showAIRecipeGenerator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AIRecipeGenerator(),
      ),
    );
  }

  // Helper to navigate to the recipe detail screen.
  void _navigateToRecipeDetail(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => RecipeDetailScreen(recipeId: recipe.id),
      ),
    );
  }

  void _handleGuideTap(Guide guide) {
    // Implement navigation to guide detail screen if needed.
  }

  void _handlePantryItemTap(PantryItem pantryItem) {
    // Implement navigation to pantry item detail screen if needed.
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'My Cookbook',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: _showAIRecipeGenerator,
              tooltip: 'Generate Recipe with AI',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => bookProvider.initData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Recipes',
            ),
            Tab(
              icon: Icon(Icons.menu_book),
              text: 'Guides',
            ),
            Tab(
              icon: Icon(Icons.kitchen),
              text: 'Pantry',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          // Recipes Tab: RecipeGrid uses the onTap callback to navigate to details.
          RecipeGrid(
            recipes: bookProvider.recipes,
            onRefresh: bookProvider.fetchRecipes,
            onTap: _navigateToRecipeDetail,
          ),
          // Guides Tab
          GuideList(
            guides: bookProvider.guides,
            onRefresh: bookProvider.fetchGuides,
            onTap: _handleGuideTap,
          ),
          // Pantry Tab
          PantryList(
            pantryItems: bookProvider.pantryItems,
            onRefresh: bookProvider.fetchPantryItems,
            onTap: _handlePantryItemTap,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _navigateToAddRecipe();
          } else if (_tabController.index == 1) {
            _navigateToAddGuide();
          } else {
            _navigateToAddPantryItem();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 0
              ? 'Add Recipe'
              : _tabController.index == 1
              ? 'Add Guide'
              : 'Add Item',
        ),
      ),
    );
  }
}
