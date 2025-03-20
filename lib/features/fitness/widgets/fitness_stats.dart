import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/fitness_provider.dart';

class FitnessStats extends StatelessWidget {
  const FitnessStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);
    
    // In a real app, these would be calculated from actual workout data
    final weeklyWorkouts = 3;
    final weeklyGoal = 5;
    final weeklyProgress = weeklyWorkouts / weeklyGoal;
    
    final totalCaloriesBurned = 850;
    final totalMinutesExercised = 120;
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          // Weekly progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workouts Completed',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$weeklyWorkouts/$weeklyGoal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: weeklyProgress,
                backgroundColor: AppColors.fitness.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.fitness),
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: totalCaloriesBurned.toString(),
                  label: 'Calories',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_outlined,
                  value: totalMinutesExercised.toString(),
                  label: 'Minutes',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today_outlined,
                  value: fitnessProvider.completedWorkouts.length.toString(),
                  label: 'Workouts',
                  color: AppColors.fitness,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  
  const _StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

