import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense
}

enum TransactionCategory {
  food,
  transportation,
  housing,
  utilities,
  entertainment,
  shopping,
  health,
  education,
  travel,
  salary,
  investment,
  other
}

class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;
  final String? accountId;
  final String? budgetId;
  
  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.accountId,
    this.budgetId,
  });
  
  Transaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionCategory? category,
    String? accountId,
    String? budgetId,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      budgetId: budgetId ?? this.budgetId,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'category': category.toString(),
      'accountId': accountId,
      'budgetId': budgetId,
    };
  }
  
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => TransactionCategory.other,
      ),
      accountId: json['accountId'],
      budgetId: json['budgetId'],
    );
  }
  
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  IconData get categoryIcon {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transportation:
        return Icons.directions_car;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.utilities:
        return Icons.power;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.health:
        return Icons.medical_services;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.travel:
        return Icons.flight;
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.other:
        return Icons.category;
      default:
        return Icons.attach_money;
    }
  }
  
  Color get categoryColor {
    switch (category) {
      case TransactionCategory.food:
        return Colors.orange;
      case TransactionCategory.transportation:
        return Colors.blue;
      case TransactionCategory.housing:
        return Colors.brown;
      case TransactionCategory.utilities:
        return Colors.amber;
      case TransactionCategory.entertainment:
        return Colors.purple;
      case TransactionCategory.shopping:
        return Colors.pink;
      case TransactionCategory.health:
        return Colors.red;
      case TransactionCategory.education:
        return Colors.indigo;
      case TransactionCategory.travel:
        return Colors.teal;
      case TransactionCategory.salary:
        return Colors.green;
      case TransactionCategory.investment:
        return Colors.lightGreen;
      case TransactionCategory.other:
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}

class Budget {
  final String id;
  final String name;
  final double amount;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final TransactionCategory category;
  
  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.spent,
    required this.startDate,
    required this.endDate,
    required this.category,
  });
  
  double get remaining => amount - spent;
  double get progress => spent / amount;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'category': category.toString(),
    };
  }
  
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      spent: json['spent'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => TransactionCategory.other,
      ),
    );
  }
}

