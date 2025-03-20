import 'package:flutter/material.dart';
import '../widgets/budget_chart.dart';
import '../widgets/budget_summary.dart';
import '../widgets/expense_list.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budget & Finance'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Show filter options
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Expenses'),
              Tab(text: 'Budgets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BudgetSummary(),
                  const SizedBox(height: 24),
                  Text(
                    'Spending Breakdown',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const BudgetChart(),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const ExpenseList(limit: 5),
                ],
              ),
            ),
            
            // Expenses Tab
            const Padding(
              padding: EdgeInsets.all(16),
              child: ExpenseList(),
            ),
            
            // Budgets Tab
            const Center(
              child: Text('Budgets Coming Soon'),
            ),
          ],
        ),
      ),
    );
  }
}

