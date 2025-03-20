import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../providers/budget_provider.dart';

class BudgetChart extends StatelessWidget {
  const BudgetChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final expensesByCategory = budgetProvider.expensesByCategory;
    
    if (expensesByCategory.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No expense data available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    
    // Calculate total expenses
    final totalExpenses = expensesByCategory.values.fold(0.0, (sum, amount) => sum + amount);
    
    // Prepare pie chart sections
    final sections = <PieChartSectionData>[];
    final legends = <Widget>[];
    
    int i = 0;
    for (final entry in expensesByCategory.entries) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;
      
      // Create pie section
      sections.add(
        PieChartSectionData(
          color: _getCategoryColor(category),
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      
      // Create legend item
      legends.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getCategoryName(category),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
      
      i++;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legends,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Expenses: ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${totalExpenses.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(TransactionCategory category) {
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
      case TransactionCategory.other:
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
  
  String _getCategoryName(TransactionCategory category) {
    return category.toString().split('.').last;
  }
}

