import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pantry_item.dart';
import '../providers/book_provider.dart';

class EditPantryItemScreen extends StatefulWidget {
  final PantryItem pantryItem;

  const EditPantryItemScreen({Key? key, required this.pantryItem}) : super(key: key);

  @override
  _EditPantryItemScreenState createState() => _EditPantryItemScreenState();
}

class _EditPantryItemScreenState extends State<EditPantryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late String _unit;
  late TextEditingController _categoryController;
  late DateTime _expiryDate;
  late bool _isInStock;

  final List<String> _unitOptions = [
    'pieces',
    'grams',
    'kg',
    'ml',
    'liters',
    'tbsp',
    'tsp',
    'cups',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pantryItem.name);
    _quantityController = TextEditingController(text: widget.pantryItem.quantity.toString());
    _unit = widget.pantryItem.unit;
    _categoryController = TextEditingController(text: widget.pantryItem.category);
    _expiryDate = widget.pantryItem.expiryDate ?? DateTime.now(); // Provide a default value
    _isInStock = widget.pantryItem.isInStock;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _updatePantryItem() {
    if (_formKey.currentState!.validate()) {
      final updatedItem = PantryItem(
        id: widget.pantryItem.id,
        name: _nameController.text,
        quantity: int.parse(_quantityController.text), // Parse as int
        unit: _unit,
        category: _categoryController.text,
        expiryDate: _expiryDate,
        isInStock: _isInStock,
      );

      Provider.of<BookProvider>(context, listen: false).updatePantryItem(updatedItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pantry Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Item'),
                  content: const Text('Are you sure you want to delete this item?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<BookProvider>(context, listen: false)
                            .deletePantryItem(widget.pantryItem.id);
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      value: _unit,
                      items: _unitOptions.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _unit = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Expiry Date'),
                subtitle: Text(
                  '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null && picked != _expiryDate) {
                    setState(() {
                      _expiryDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('In Stock'),
                value: _isInStock,
                onChanged: (bool value) {
                  setState(() {
                    _isInStock = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updatePantryItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Update Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
