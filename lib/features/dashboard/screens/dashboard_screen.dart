import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/daily_timeline.dart';
import '../widgets/date_selector.dart';
import '../widgets/greeting_header.dart';
import '../widgets/module_summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Use GoRouter's pushNamed method with the route name "settings"
              context.pushNamed('settings');
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GreetingHeader(),
                    const SizedBox(height: 24),
                    Container(
                      height: 120,
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
                      child: const DateSelector(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Daily Planner',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    const DailyTimeline(),
                    const SizedBox(height: 24),
                    Text(
                      'Module Summaries',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ModuleSummaryCard(
                      title: 'Fitness',
                      icon: Icons.fitness_center,
                      color: AppColors.fitness,
                      summary: 'Today\'s workout: HIIT - 30 min',
                      progress: 0.6,
                    ),
                    const SizedBox(height: 12),
                    ModuleSummaryCard(
                      title: 'Budget',
                      icon: Icons.account_balance_wallet,
                      color: AppColors.budget,
                      summary: 'Monthly budget: 65% remaining',
                      progress: 0.65,
                    ),
                    const SizedBox(height: 12),
                    ModuleSummaryCard(
                      title: 'Tasks',
                      icon: Icons.check_circle,
                      color: AppColors.tasks,
                      summary: '3 tasks due today',
                      progress: 0.4,
                    ),
                    const SizedBox(height: 12),
                    ModuleSummaryCard(
                      title: 'Book',
                      icon: Icons.book,
                      color: AppColors.book,
                      summary: 'Recipe of the day: Avocado Toast',
                      progress: 0.8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
