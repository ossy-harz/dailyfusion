import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/fitness_provider.dart';

class WorkoutCalendar extends StatelessWidget {
  const WorkoutCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = Provider.of<FitnessProvider>(context);
    final selectedDate = fitnessProvider.selectedDate;
    
    // Generate dates for the next 14 days
    final dates = List.generate(14, (index) {
      return DateTime.now().add(Duration(days: index - 7));
    });
    
    return Container(
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today, size: 20),
                      onPressed: () {
                        // Show date picker
                        showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        ).then((date) {
                          if (date != null) {
                            fitnessProvider.setSelectedDate(date);
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.today, size: 20),
                      onPressed: () {
                        // Set to today
                        fitnessProvider.setSelectedDate(DateTime.now());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = DateUtils.isSameDay(date, selectedDate);
                
                // In a real app, this would check if there are workouts scheduled for this date
                final hasWorkout = date.day % 2 == 0;
                
                return GestureDetector(
                  onTap: () {
                    fitnessProvider.setSelectedDate(date);
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.fitness
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // In workout_calendar.dart, modify the Column in the GestureDetector
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day abbreviation
                        Text(
                          DateFormat('E').format(date).substring(0, 1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12, // Add explicit font size
                          ),
                        ),
                        const SizedBox(height: 2), // Reduce spacing
                        // Day number
                        Text(
                          date.day.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.titleMedium?.color,
                            fontWeight: isSelected ? FontWeight.bold : null,
                            fontSize: 14, // Add explicit font size
                          ),
                        ),
                        const SizedBox(height: 2), // Reduce spacing
                        // Workout indicator
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasWorkout
                                ? (isSelected ? Colors.white : AppColors.fitness)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

