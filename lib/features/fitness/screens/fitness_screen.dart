import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fitness_provider.dart';
import '../widgets/fitness_stats.dart';
import '../widgets/workout_calendar.dart';
import '../widgets/workout_card.dart';

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness & Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              // Navigate to fitness insights
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FitnessStats(),
            const SizedBox(height: 24),
            Text(
              'Workout Calendar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const WorkoutCalendar(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended Workouts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all workouts
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<FitnessProvider>(
              builder: (context, fitnessProvider, _) {
                final workouts = fitnessProvider.recommendedWorkouts;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: WorkoutCard(workout: workouts[index]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

