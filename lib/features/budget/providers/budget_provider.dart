import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/transaction.dart';

class BudgetProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  
  // Get total income
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  // Get total expenses
  double get totalExpenses {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  // Get balance
  double get balance => totalIncome - totalExpenses;
  
  // Get recent transactions
  List<Transaction> getRecentTransactions({int limit = 10}) {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return sorted.take(limit).toList();
  }
  
  // Get transactions by category
  Map<TransactionCategory, double> get expensesByCategory {
    final result = <TransactionCategory, double>{};
    
    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        final category = transaction.category;
        result[category] = (result[category] ?? 0) + transaction.amount;
      }
    }
    
    return result;
  }
  
  BudgetProvider() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final transactionData = await _storageService.getCollection('transactions');
      _transactions = transactionData.map((json) => Transaction.fromJson(json)).toList();
      
      final budgetData = await _storageService.getCollection('budgets');
      _budgets = budgetData.map((json) => Budget.fromJson(json)).toList();
      
      // If no data exists, add sample data
      if (_transactions.isEmpty) {
        _addSampleData();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading budget data: $e');
      _addSampleData();
    }
  }
  
  void _addSampleData() {
    // Sample transactions
    _transactions = [
      Transaction(
        id: '1',
        title: 'Salary',
        description: 'Monthly salary',
        amount: 3000,
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: TransactionType.income,
        category: TransactionCategory.salary,
      ),
      Transaction(
        id: '2',
        title: 'Rent',
        description: 'Monthly rent',
        amount: 1200,
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: TransactionType.expense,
        category: TransactionCategory.housing,
      ),
      Transaction(
        id: '3',
        title: 'Groceries',
        description: 'Weekly groceries',
        amount: 85.50,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: TransactionType.expense,
        category: TransactionCategory.food,
      ),
      Transaction(
        id: '4',
        title: 'Dinner',
        description: 'Restaurant dinner',
        amount: 45.80,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        category: TransactionCategory.food,
      ),
      Transaction(
        id: '5',
        title: 'Gas',
        description: 'Car fuel',
        amount: 35.20,
        date: DateTime.now(),
        type: TransactionType.expense,
        category: TransactionCategory.transportation,
      ),
    ];
    
    // Sample budgets
    _budgets = [
      Budget(
        id: '1',
        name: 'Food',
        amount: 500,
        spent: 131.30,
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
        category: TransactionCategory.food,
      ),
      Budget(
        id: '2',
        name: 'Transportation',
        amount: 200,
        spent: 35.20,
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
        category: TransactionCategory.transportation,
      ),
      Budget(
        id: '3',
        name: 'Entertainment',
        amount: 150,
        spent: 0,
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
        category: TransactionCategory.entertainment,
      ),
    ];
    
    notifyListeners();
  }
  
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    
    // Update budget if applicable
    if (transaction.type == TransactionType.expense && transaction.budgetId != null) {
      final budgetIndex = _budgets.indexWhere((b) => b.id == transaction.budgetId);
      if (budgetIndex != -1) {
        final budget = _budgets[budgetIndex];
        _budgets[budgetIndex] = Budget(
          id: budget.id,
          name: budget.name,
          amount: budget.amount,
          spent: budget.spent + transaction.amount,
          startDate: budget.startDate,
          endDate: budget.endDate,
          category: budget.category,
        );
      }
    }
    
    await _storageService.addDocument('transactions', transaction.toJson());
    notifyListeners();
  }
  
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _storageService.updateDocument('transactions', transaction.id, transaction.toJson());
      notifyListeners();
    }
  }
  
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storageService.deleteDocument('transactions', id);
    notifyListeners();
  }
  
  Future<void> addBudget(Budget budget) async {
    _budgets.add(budget);
    await _storageService.addDocument('budgets', budget.toJson());
    notifyListeners();
  }
  
  Future<void> updateBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      await _storageService.updateDocument('budgets', budget.id, budget.toJson());
      notifyListeners();
    }
  }
  
  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _storageService.deleteDocument('budgets', id);
    notifyListeners();
  }
}

