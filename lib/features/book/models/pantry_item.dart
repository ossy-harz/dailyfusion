class PantryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime? expiryDate;
  bool isInStock;

  PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.isInStock,
  });

  PantryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    DateTime? expiryDate,
    bool? isInStock,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      isInStock: isInStock ?? this.isInStock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'isInStock': isInStock,
    };
  }

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Other',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiryDate'])
          : null,
      isInStock: json['isInStock'] ?? false,
    );
  }
}
