import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/analytics_utils.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const ReportsScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final grouped = groupByMonth(expenses);
    if (grouped.isEmpty) {
      return const Center(child: Text('Нет данных для отчета'));
    }

    final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: months.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final month = months[index];
        final total = grouped[month]!;
        final prevMonth = DateTime(month.year, month.month - 1, 1);
        final prevTotal = grouped[prevMonth] ?? 0.0;

        final percent = percentChange(prevTotal, total);
        final changeText = percent == null
            ? '—'
            : 'На ${percent.abs().toStringAsFixed(0)}% ${percent < 0 ? 'меньше' : 'больше'}';
        final isDecrease = percent != null && percent < 0;
        final isIncrease = percent != null && percent > 0;
        final color = isDecrease
            ? Colors.green
            : isIncrease
                ? Colors.red
                : Colors.grey;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatMonthHeader(month),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Сравнение с прошлым месяцем',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${formatAmount(total)} BYN',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      changeText,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
