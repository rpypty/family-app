import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/tag.dart';
import '../utils/analytics_utils.dart';
import '../utils/formatters.dart';
import '../utils/tag_utils.dart';
import '../widgets/date_input.dart';
import '../widgets/pie_chart.dart';
import '../widgets/quick_filter_chip.dart';
import '../widgets/tag_picker_input.dart';
import '../widgets/tag_row.dart';
import '../widgets/tag_search_dialog.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Tag> tags;

  const AnalyticsScreen({
    super.key,
    required this.expenses,
    required this.tags,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final Set<String> _filterTagIds = {};

  Future<void> _pickFromDate() async {
    final initial = _fromDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    setState(() {
      _fromDate = selected;
    });
  }

  Future<void> _pickToDate() async {
    final initial = _toDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    setState(() {
      _toDate = selected;
    });
  }

  void _applyQuickRange(int days) {
    final today = dateOnly(DateTime.now());
    setState(() {
      _toDate = today;
      _fromDate = today.subtract(Duration(days: days - 1));
    });
  }

  void _applyFromDay(int dayOfMonth) {
    final today = dateOnly(DateTime.now());
    final date = latestDayOfMonth(dayOfMonth, today);
    setState(() {
      _fromDate = date;
      _toDate = today;
    });
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _filterTagIds.clear();
    });
  }

  bool _matchesFilters(Expense expense) {
    final date = dateOnly(expense.date);
    DateTime? from = _fromDate == null ? null : dateOnly(_fromDate!);
    DateTime? to = _toDate == null ? null : dateOnly(_toDate!);
    if (from != null && to != null && from.isAfter(to)) {
      final temp = from;
      from = to;
      to = temp;
    }
    if (from != null && date.isBefore(from)) {
      return false;
    }
    if (to != null && date.isAfter(to)) {
      return false;
    }
    if (_filterTagIds.isNotEmpty) {
      final hasAny = expense.tagIds.any(_filterTagIds.contains);
      if (!hasAny) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.expenses.where(_matchesFilters).toList();
    final filteredSorted = filtered.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final totalsByCurrency = aggregateByCurrency(filtered);
    final totalsByTag = aggregateByTag(filtered);
    final hasFilters =
        _fromDate != null || _toDate != null || _filterTagIds.isNotEmpty;

    final currencyLabel =
        totalsByCurrency.length == 1 ? totalsByCurrency.keys.first : '';
    final slices = _buildSlices(totalsByTag, widget.tags);
    final totalByTags =
        slices.fold<double>(0, (sum, slice) => sum + slice.value);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Фильтры',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DateInput(
                        label: 'Дата от',
                        value: _fromDate == null ? null : formatDate(_fromDate!),
                        onTap: _pickFromDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DateInput(
                        label: 'Дата до',
                        value: _toDate == null ? null : formatDate(_toDate!),
                        onTap: _pickToDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    QuickFilterChip(
                      label: 'За неделю',
                      onTap: () => _applyQuickRange(7),
                    ),
                    QuickFilterChip(
                      label: 'За месяц',
                      onTap: () => _applyQuickRange(30),
                    ),
                    QuickFilterChip(
                      label: 'От 5 числа',
                      onTap: () => _applyFromDay(5),
                    ),
                    QuickFilterChip(
                      label: 'От 20 числа',
                      onTap: () => _applyFromDay(20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Теги',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                TagPickerInput(
                  label: 'Выбрать тег',
                  onTap: () async {
                    final selected = await showTagSearchDialog(
                      context: context,
                      tags: widget.tags,
                      initialSelected: _filterTagIds,
                    );
                    if (selected == null) return;
                    setState(() {
                      _filterTagIds
                        ..clear()
                        ..addAll(selected);
                    });
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_filterTagIds.isEmpty)
                      const Text('Теги не выбраны')
                    else
                      for (final tag in selectedTags(
                        widget.tags,
                        _filterTagIds,
                      ))
                        InputChip(
                          label: Text(tag.name),
                          onDeleted: () {
                            setState(() {
                              _filterTagIds.remove(tag.uuid);
                            });
                          },
                        ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Сбросить фильтры'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: totalsByCurrency.isEmpty
                ? const Text('Сумма: 0')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Сумма по фильтрам:'),
                      const SizedBox(height: 4),
                      for (final entry in totalsByCurrency.entries)
                        Text(
                          '${formatAmount(entry.value)} ${entry.key}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Траты по тегам',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (slices.isEmpty)
                  const Text('Нет данных для диаграммы')
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: PieChart(slices: slices, size: 180)),
                      const SizedBox(height: 12),
                      for (final slice in slices)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: slice.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(slice.label),
                              ),
                              Text(
                                '${formatPercent(slice.value, totalByTags)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currencyLabel.isEmpty
                                    ? formatAmount(slice.value)
                                    : '${formatAmount(slice.value)} $currencyLabel',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (hasFilters) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Список по фильтрам',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (filtered.isEmpty)
                    const Text('Нет подходящих записей')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSorted.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final expense = filteredSorted[index];
                        final tagNames = expense.tagIds
                            .map((id) => widget.tags.firstWhere(
                                  (tag) => tag.uuid == id,
                                  orElse: () => Tag()
                                    ..uuid = ''
                                    ..name = '',
                                ))
                            .where((tag) => tag.uuid.isNotEmpty)
                            .map((tag) => tag.name)
                            .toList();
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            expense.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tagNames.isNotEmpty)
                                const SizedBox(height: 4),
                              if (tagNames.isNotEmpty)
                                TagRow(
                                  tagNames: tagNames,
                                  maxVisible: 3,
                                  onShowAll: () =>
                                      showAllTags(context, tagNames),
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${formatAmount(expense.amount)} ${expense.currency}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

List<PieSlice> _buildSlices(Map<String, double> totals, List<Tag> tags) {
  final palette = [
    Colors.teal,
    Colors.blue,
    Colors.orange,
    Colors.pink,
    Colors.green,
    Colors.indigo,
    Colors.redAccent,
    Colors.cyan,
  ];

  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return [
    for (var i = 0; i < entries.length; i++)
      PieSlice(
        label: tags
            .firstWhere(
              (tag) => tag.uuid == entries[i].key,
              orElse: () => Tag()
                ..uuid = ''
                ..name = 'Без тега',
            )
            .name,
        value: entries[i].value,
        color: palette[i % palette.length],
      ),
  ];
}
