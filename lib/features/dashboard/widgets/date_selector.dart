import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final selectedDate = dashboardProvider.selectedDate;

    return Container(
      height: 100,
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
                            dashboardProvider.setSelectedDate(date);
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.today, size: 20),
                      onPressed: () {
                        // Set to today
                        dashboardProvider.setSelectedDate(DateTime.now());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(14, (index) {
                  final date = DateTime.now().add(Duration(days: index - 7));
                  final isSelected = DateUtils.isSameDay(date, selectedDate);

                  return GestureDetector(
                    onTap: () {
                      dashboardProvider.setSelectedDate(date);
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(date).substring(0, 1),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).textTheme.titleMedium?.color,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
