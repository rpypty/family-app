import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/tag.dart';
import '../utils/formatters.dart';
import 'tag_row.dart';

class ExpenseListView extends StatelessWidget {
  final List<Expense> expenses;
  final List<Tag> tags;
  final ValueChanged<Expense> onEdit;

  const ExpenseListView({
    super.key,
    required this.expenses,
    required this.tags,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = expenses.toList()..sort((a, b) => b.date.compareTo(a.date));

    if (sorted.isEmpty) {
      return const Center(child: Text('Пока нет расходов'));
    }

    final grouped = <DateTime, List<Expense>>{};
    for (final expense in sorted) {
      final day = dateOnly(expense.date);
      grouped.putIfAbsent(day, () => []).add(expense);
    }

    final sections = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final items = <Widget>[];
    for (final day in sections) {
      final dayExpenses = grouped[day]!;
      final totals = aggregateByCurrency(dayExpenses);
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  formatDayHeader(day),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                formatTotals(totals),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      );

      for (final expense in dayExpenses) {
        final tagNames = expense.tagIds
            .map((id) => tags.firstWhere(
                  (tag) => tag.uuid == id,
                  orElse: () => Tag()
                    ..uuid = ''
                    ..name = '',
                ))
            .where((tag) => tag.uuid.isNotEmpty)
            .map((tag) => tag.name)
            .toList();
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Card(
              child: ListTile(
                title: Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tagNames.isNotEmpty) const SizedBox(height: 4),
                    if (tagNames.isNotEmpty)
                      TagRow(
                        tagNames: tagNames,
                        maxVisible: 3,
                        onShowAll: () => showAllTags(context, tagNames),
                      ),
                  ],
                ),
                trailing: Text(
                  '${formatAmount(expense.amount)} ${expense.currency}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => onEdit(expense),
              ),
            ),
          ),
        );
      }
    }

    return ListView(children: items);
  }
}
