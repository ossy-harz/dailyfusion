import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pantry_item.dart';
import '../providers/book_provider.dart';
import '../screens/add_pantry_item_screen.dart';
import '../screens/edit_pantry_item_screen.dart';

class PantryList extends StatefulWidget {
  const PantryList({Key? key, required List<PantryItem> pantryItems, required Future<void> Function() onRefresh, required void Function(PantryItem pantryItem) onTap}) : super(key: key);

  @override
  _PantryListState createState() => _PantryListState();
}

class _PantryListState extends State<PantryList> {
  String _filterCategory = 'All';
  bool _showOnlyInStock = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddPantryItemScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddPantryItemScreen(),
      ),
    );
  }

  void _navigateToEditPantryItemScreen(PantryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EditPantryItemScreen(pantryItem: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final pantryItems = bookProvider.pantryItems;

    // Get unique categories for filter
    final categories = ['All', ...{...pantryItems.map((item) => item.category)}];

    // Apply filters
    var filteredItems = pantryItems.where((item) {
      // Category filter
      if (_filterCategory != 'All' && item.category != _filterCategory) {
        return false;
      }

      // Stock filter
      if (_showOnlyInStock && !item.isInStock) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.category.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();

    // Sort by expiry date, handling null values
    filteredItems.sort((a, b) {
      final dateA = a.expiryDate ?? DateTime.now();
      final dateB = b.expiryDate ?? DateTime.now();
      return dateA.compareTo(dateB);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search pantry items',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Filter by Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _filterCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _filterCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilterChip(
                    label: const Text('In Stock Only'),
                    selected: _showOnlyInStock,
                    onSelected: (selected) {
                      setState(() {
                        _showOnlyInStock = selected;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No pantry items found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _navigateToAddPantryItemScreen,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (ctx, index) {
              final item = filteredItems[index];
              final daysUntilExpiry = item.expiryDate?.difference(DateTime.now()).inDays;

              // Determine color based on expiry
              Color? expiryColor;
              if (daysUntilExpiry != null) {
                if (daysUntilExpiry < 0) {
                  expiryColor = Colors.red;
                } else if (daysUntilExpiry < 3) {
                  expiryColor = Colors.orange;
                } else if (daysUntilExpiry < 7) {
                  expiryColor = Colors.amber;
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.isInStock ? Colors.green : Colors.grey,
                    child: Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: !item.isInStock ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.quantity} ${item.unit} • ${item.category}'),
                      if (item.expiryDate != null)
                        Text(
                          'Expires: ${item.expiryDate!.day}/${item.expiryDate!.month}/${item.expiryDate!.year}',
                          style: TextStyle(
                            color: expiryColor,
                            fontWeight: expiryColor != null ? FontWeight.bold : null,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          item.isInStock ? Icons.check_circle : Icons.check_circle_outline,
                          color: item.isInStock ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          final updatedItem = PantryItem(
                            id: item.id,
                            name: item.name,
                            quantity: item.quantity,
                            unit: item.unit,
                            category: item.category,
                            expiryDate: item.expiryDate,
                            isInStock: !item.isInStock,
                          );
                          bookProvider.updatePantryItem(updatedItem);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToEditPantryItemScreen(item),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToEditPantryItemScreen(item),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _navigateToAddPantryItemScreen,
            icon: const Icon(Icons.add),
            label: const Text('Add Pantry Item'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ],
    );
  }
}
