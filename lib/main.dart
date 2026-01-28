import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatefulWidget {
  const ExpenseApp({super.key});

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomeScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class Expense {
  final String id;
  final DateTime date;
  final double amount;
  final String currency;
  final String title;
  final List<String> tagIds;

  const Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.currency,
    required this.title,
    required this.tagIds,
  });

  Expense copyWith({
    DateTime? date,
    double? amount,
    String? currency,
    String? title,
    List<String>? tagIds,
  }) {
    return Expense(
      id: id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      title: title ?? this.title,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}

class Tag {
  final String id;
  final String name;

  const Tag({required this.id, required this.name});
}

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [];
  final List<Tag> _tags = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _seedMockData();
  }

  void _seedMockData() {
    if (_expenses.isNotEmpty || _tags.isNotEmpty) return;

    final random = Random();
    final tagNames = [
      'Еда',
      'Транспорт',
      'Дом',
      'Отдых',
      'Кафе',
      'Рестораны',
      'Супермаркет',
      'Доставка',
      'Топливо',
      'Парковка',
      'Такси',
      'Метро',
      'Автобус',
      'Связь',
      'Интернет',
      'Подписки',
      'Развлечения',
      'Спорт',
      'Здоровье',
      'Аптека',
      'Подарки',
      'Одежда',
      'Обувь',
      'Образование',
      'Книги',
      'Путешествия',
      'Домашние',
      'Ремонт',
      'Красота',
      'Дети',
      'Питомцы',
      'Хобби',
      'Техника',
      'Коммунальные',
      'Финансы',
    ];

    final tags = [
      for (final name in tagNames)
        Tag(id: generateUuidV4(), name: name),
    ];
    _tags.addAll(tags);
    final titles = [
      'Кофе и выпечка',
      'Продукты',
      'Такси',
      'Метро',
      'Обед',
      'Ужин',
      'Кино',
      'Хозтовары',
      'Заправка',
      'Подарок',
      'Книги',
      'Аптека',
      'Доставка',
      'Связь',
    ];

    final today = dateOnly(DateTime.now());
    final daysToGenerate = 420; // чтобы был прошлый год + текущий
    final targetCount = 500;
    var added = 0;

    for (var i = 0; i < daysToGenerate && added < targetCount; i++) {
      final day = today.subtract(Duration(days: i));
      final perDay = 1 + random.nextInt(4); // 1-4 записей в день
      for (var j = 0; j < perDay && added < targetCount; j++) {
        final tagCount = 1 + random.nextInt(2);
        final picked = <Tag>{};
        while (picked.length < tagCount) {
          picked.add(tags[random.nextInt(tags.length)]);
        }

        final amount = (5 + random.nextInt(150)) + random.nextDouble();
        _expenses.add(
          Expense(
            id: generateUuidV4(),
            date: day,
            amount: double.parse(amount.toStringAsFixed(2)),
            currency: 'BYN',
            title: titles[random.nextInt(titles.length)],
            tagIds: picked.map((tag) => tag.id).toList(),
          ),
        );
        added++;
      }
    }

    // гарантируем записи сегодня и вчера
    _expenses.addAll([
      Expense(
        id: generateUuidV4(),
        date: today,
        amount: 12.40,
        currency: 'BYN',
        title: 'Сегодня: кофе',
        tagIds: [tags[0].id],
      ),
      Expense(
        id: generateUuidV4(),
        date: today.subtract(const Duration(days: 1)),
        amount: 28.30,
        currency: 'BYN',
        title: 'Вчера: такси',
        tagIds: [tags[1].id],
      ),
    ]);
  }

  void _openCreate() async {
    final result = await Navigator.of(context).push<ExpenseFormResult>(
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(
          tags: _tags,
          onCreateTag: _createTag,
        ),
      ),
    );

    if (result == null) return;
    if (result.action == ExpenseFormAction.save && result.expense != null) {
      setState(() {
        _expenses.add(result.expense!);
      });
    }
  }

  void _openEdit(Expense expense) async {
    final result = await Navigator.of(context).push<ExpenseFormResult>(
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(
          expense: expense,
          tags: _tags,
          onCreateTag: _createTag,
        ),
      ),
    );

    if (result == null) return;

    if (result.action == ExpenseFormAction.delete) {
      setState(() {
        _expenses.removeWhere((e) => e.id == expense.id);
      });
      return;
    }

    if (result.action == ExpenseFormAction.save && result.expense != null) {
      setState(() {
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index >= 0) {
          _expenses[index] = result.expense!;
        }
      });
    }
  }

  Tag _createTag(String name) {
    final tag = Tag(id: generateUuidV4(), name: name);
    setState(() {
      _tags.add(tag);
    });
    return tag;
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Расходы', 'Аналитика', 'Отчеты'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDark ? 'Светлая тема' : 'Темная тема',
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ExpenseListView(
            expenses: _expenses,
            tags: _tags,
            onEdit: _openEdit,
          ),
          AnalyticsScreen(
            expenses: _expenses,
            tags: _tags,
          ),
          ReportsScreen(expenses: _expenses),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _openCreate,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Список',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Аналитика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Отчеты',
          ),
        ],
      ),
    );
  }
}

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

    final sections = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final items = <Widget>[];
    for (final day in sections) {
      final dayExpenses = grouped[day]!;
      final totals = _aggregateByCurrency(dayExpenses);
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
                  (tag) => tag.id == id,
                  orElse: () => const Tag(id: '', name: ''),
                ))
            .where((tag) => tag.id.isNotEmpty)
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
                  _TagRow(
                    tagNames: tagNames,
                    maxVisible: 3,
                    onShowAll: () => _showAllTags(context, tagNames),
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
    final date = _latestDayOfMonth(dayOfMonth, today);
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

  Map<String, double> _aggregateByCurrency(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals.update(
        expense.currency,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totals;
  }

  Map<String, double> _aggregateByTag(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      for (final tagId in expense.tagIds) {
        if (_filterTagIds.isNotEmpty && !_filterTagIds.contains(tagId)) {
          continue;
        }
        totals.update(
          tagId,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.expenses.where(_matchesFilters).toList();
    final filteredSorted = filtered.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final totalsByCurrency = _aggregateByCurrency(filtered);
    final totalsByTag = _aggregateByTag(filtered);
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
                      child: _DateInput(
                        label: 'Дата от',
                        value:
                            _fromDate == null ? null : formatDate(_fromDate!),
                        onTap: _pickFromDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DateInput(
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
                    _QuickFilterChip(
                      label: 'За неделю',
                      onTap: () => _applyQuickRange(7),
                    ),
                    _QuickFilterChip(
                      label: 'За месяц',
                      onTap: () => _applyQuickRange(30),
                    ),
                    _QuickFilterChip(
                      label: 'От 5 числа',
                      onTap: () => _applyFromDay(5),
                    ),
                    _QuickFilterChip(
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
                _TagPickerInput(
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
                      for (final tag in _selectedTags(
                        widget.tags,
                        _filterTagIds,
                      ))
                        InputChip(
                          label: Text(tag.name),
                          onDeleted: () {
                            setState(() {
                              _filterTagIds.remove(tag.id);
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
                                '${_formatPercent(slice.value, totalByTags)}%',
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
                                  (tag) => tag.id == id,
                                  orElse: () => const Tag(id: '', name: ''),
                                ))
                            .where((tag) => tag.id.isNotEmpty)
                            .map((tag) => tag.name)
                            .toList();
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            expense.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatDate(expense.date),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (tagNames.isNotEmpty)
                                const SizedBox(height: 4),
                              if (tagNames.isNotEmpty)
                                _TagRow(
                                  tagNames: tagNames,
                                  maxVisible: 3,
                                  onShowAll: () =>
                                      _showAllTags(context, tagNames),
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${formatAmount(expense.amount)} ${expense.currency}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
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

class ReportsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const ReportsScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByMonth(expenses);
    if (grouped.isEmpty) {
      return const Center(child: Text('Нет данных для отчета'));
    }

    final months = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: months.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final month = months[index];
        final total = grouped[month]!;
        final prevMonth = DateTime(month.year, month.month - 1, 1);
        final prevTotal = grouped[prevMonth] ?? 0.0;

        final percentChange = _percentChange(prevTotal, total);
        final changeText = percentChange == null
            ? '—'
            : 'На ${percentChange.abs().toStringAsFixed(0)}% ${percentChange < 0 ? 'меньше' : 'больше'}';
        final isDecrease = percentChange != null && percentChange < 0;
        final isIncrease = percentChange != null && percentChange > 0;
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

class _DateInput extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DateInput({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Text(value ?? '—'),
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickFilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _TagPickerInput extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TagPickerInput({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: const Text('Нажмите для выбора'),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  final List<String> tagNames;
  final int maxVisible;
  final VoidCallback? onShowAll;

  const _TagRow({
    required this.tagNames,
    this.maxVisible = 3,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final visible = tagNames.take(maxVisible).toList();
    final remaining = tagNames.length - visible.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final name in visible)
          Chip(
            label: Text(
              name,
              style: const TextStyle(fontSize: 12),
            ),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: -2,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        if (remaining > 0)
          GestureDetector(
            onTap: onShowAll,
            child: Chip(
              label: Text(
                'еще $remaining ${_pluralTag(remaining)}',
                style: const TextStyle(fontSize: 12),
              ),
              visualDensity: VisualDensity.compact,
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: -2,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }
}

Future<Set<String>?> showTagSearchDialog({
  required BuildContext context,
  required List<Tag> tags,
  required Set<String> initialSelected,
  Tag Function(String name)? onCreateTag,
}) {
  final selected = {...initialSelected};
  final controller = TextEditingController();

  return showDialog<Set<String>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final query = controller.text.trim().toLowerCase();
          final filtered = query.isEmpty
              ? tags
              : tags
                  .where(
                    (tag) => tag.name.toLowerCase().contains(query),
                  )
                  .toList();

          return AlertDialog(
            title: const Text('Поиск тегов'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Найти тег',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: filtered.isEmpty
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Ничего не найдено'),
                              if (onCreateTag != null && query.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: FilledButton.icon(
                                    onPressed: () {
                                      final name = query.trim();
                                      if (name.isEmpty) return;
                                      final existing = _findTagByName(
                                        tags,
                                        name,
                                      );
                                      final tag = existing ??
                                          onCreateTag(name);
                                      selected.add(tag.id);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add),
                                    label:
                                        Text('Добавить тег \"$query\"'),
                                  ),
                                ),
                            ],
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final tag = filtered[index];
                              final isSelected = selected.contains(tag.id);
                              return CheckboxListTile(
                                value: isSelected,
                                dense: true,
                                title: Text(tag.name),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selected.add(tag.id);
                                    } else {
                                      selected.remove(tag.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(selected),
                child: const Text('Готово'),
              ),
            ],
          );
        },
      );
    },
  );
}

List<Tag> _selectedTags(List<Tag> tags, Set<String> selectedIds) {
  return tags.where((tag) => selectedIds.contains(tag.id)).toList();
}

Tag? _findTagByName(List<Tag> tags, String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  for (final tag in tags) {
    if (tag.name.toLowerCase() == normalized) {
      return tag;
    }
  }
  return null;
}

String _pluralTag(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) return 'тег';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'тега';
  }
  return 'тегов';
}

void _showAllTags(BuildContext context, List<String> tagNames) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in tagNames)
              Chip(
                label: Text(name),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      );
    },
  );
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
              (tag) => tag.id == entries[i].key,
              orElse: () => const Tag(id: '', name: 'Без тега'),
            )
            .name,
        value: entries[i].value,
        color: palette[i % palette.length],
      ),
  ];
}

class PieSlice {
  final String label;
  final double value;
  final Color color;

  const PieSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class PieChart extends StatelessWidget {
  final List<PieSlice> slices;
  final double size;

  const PieChart({
    super.key,
    required this.slices,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    if (total <= 0) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: Text('0')),
      );
    }
    return CustomPaint(
      size: Size(size, size),
      painter: PieChartPainter(
        slices: slices,
        total: total,
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<PieSlice> slices;
  final double total;

  PieChartPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    var startAngle = -pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweep, true, paint);

      final percent = (slice.value / total) * 100;
      if (percent >= 6) {
        final midAngle = startAngle + sweep / 2;
        final radius = size.width / 2;
        final labelRadius = radius * 0.62;
        final offset = Offset(
          radius + labelRadius * cos(midAngle),
          radius + labelRadius * sin(midAngle),
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${percent.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          offset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

enum ExpenseFormAction { save, delete }

class ExpenseFormResult {
  final ExpenseFormAction action;
  final Expense? expense;

  const ExpenseFormResult({required this.action, this.expense});
}

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  final List<Tag> tags;
  final Tag Function(String name) onCreateTag;

  const ExpenseFormScreen({
    super.key,
    this.expense,
    required this.tags,
    required this.onCreateTag,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  late DateTime _date;
  late TextEditingController _amountController;
  late TextEditingController _titleController;
  String _currency = 'BYN';
  late Set<String> _selectedTagIds;

  @override
  void initState() {
    super.initState();
    _date = widget.expense?.date ?? DateTime.now();
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _titleController = TextEditingController(
      text: widget.expense?.title ?? '',
    );
    _currency = widget.expense?.currency ?? 'BYN';
    _selectedTagIds = widget.expense?.tagIds.toSet() ?? <String>{};
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate = _date;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    setState(() {
      _date = selected;
    });
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    final title = _titleController.text.trim();

    if (amount == null || amount <= 0 || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректные данные')),
      );
      return;
    }

    final expense = (widget.expense == null)
        ? Expense(
            id: generateUuidV4(),
            date: _date,
            amount: amount,
            currency: _currency,
            title: title,
            tagIds: _selectedTagIds.toList(),
          )
        : widget.expense!.copyWith(
            date: _date,
            amount: amount,
            currency: _currency,
            title: title,
            tagIds: _selectedTagIds.toList(),
          );

    Navigator.of(context).pop(
      ExpenseFormResult(action: ExpenseFormAction.save, expense: expense),
    );
  }

  void _delete() {
    Navigator.of(context).pop(
      const ExpenseFormResult(action: ExpenseFormAction.delete),
    );
  }

  Future<void> _addTagDialog() async {
    final controller = TextEditingController();
    final newTagName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новый тег'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Название тега',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                Navigator.of(context).pop(name.isEmpty ? null : name);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );

    if (newTagName == null || newTagName.isEmpty) return;
    final existing = widget.tags.firstWhere(
      (tag) => tag.name.toLowerCase() == newTagName.toLowerCase(),
      orElse: () => const Tag(id: '', name: ''),
    );
    final tag = existing.id.isNotEmpty ? existing : widget.onCreateTag(newTagName);
    setState(() {
      _selectedTagIds.add(tag.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование' : 'Новый расход'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дата', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(formatDate(_date))),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Выбрать'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Валюта',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'BYN', child: Text('BYN')),
                      DropdownMenuItem(value: 'RUB', child: Text('RUB')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _currency = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Теги', style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addTagDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Новый тег'),
                ),
              ],
            ),
            _TagPickerInput(
              label: 'Выбрать тег',
              onTap: () async {
                final selected = await showTagSearchDialog(
                  context: context,
                  tags: widget.tags,
                  initialSelected: _selectedTagIds,
                  onCreateTag: widget.onCreateTag,
                );
                if (selected == null) return;
                setState(() {
                  _selectedTagIds
                    ..clear()
                    ..addAll(selected);
                });
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (_selectedTagIds.isEmpty)
                  const Text('Теги не выбраны')
                else
                  for (final tag in _selectedTags(
                    widget.tags,
                    _selectedTagIds,
                  ))
                    InputChip(
                      label: Text(tag.name),
                      onDeleted: () {
                        setState(() {
                          _selectedTagIds.remove(tag.id);
                        });
                      },
                    ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                if (isEditing)
                  TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Удалить'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String formatAmount(double amount) {
  return amount.toStringAsFixed(2);
}

String _formatPercent(double value, double total) {
  if (total <= 0) return '0';
  return ((value / total) * 100).toStringAsFixed(0);
}

Map<String, double> _aggregateByCurrency(List<Expense> expenses) {
  final totals = <String, double>{};
  for (final expense in expenses) {
    totals.update(
      expense.currency,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
}

String formatTotals(Map<String, double> totals) {
  if (totals.isEmpty) return '0';
  return totals.entries
      .map((entry) => '${formatAmount(entry.value)} ${entry.key}')
      .join(' · ');
}

String formatDayHeader(DateTime day) {
  final today = dateOnly(DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));
  final target = dateOnly(day);
  if (target == today) return 'Сегодня';
  if (target == yesterday) return 'Вчера';
  return formatDayWithMonth(target);
}

Map<DateTime, double> _groupByMonth(List<Expense> expenses) {
  final totals = <DateTime, double>{};
  for (final expense in expenses) {
    final key = DateTime(expense.date.year, expense.date.month, 1);
    totals.update(
      key,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
}

String formatMonthHeader(DateTime month) {
  const months = [
    'январь',
    'февраль',
    'март',
    'апрель',
    'май',
    'июнь',
    'июль',
    'август',
    'сентябрь',
    'октябрь',
    'ноябрь',
    'декабрь',
  ];
  final name = months[month.month - 1];
  return '${name[0].toUpperCase()}${name.substring(1)} ${month.year}';
}

String formatDayWithMonth(DateTime day) {
  const monthsGenitive = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  final today = DateTime.now();
  final base = '${day.day} ${monthsGenitive[day.month - 1]}';
  if (day.year != today.year) {
    return '$base ${day.year}';
  }
  return base;
}

double? _percentChange(double previous, double current) {
  if (previous == 0) return null;
  return ((current - previous) / previous) * 100;
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime _latestDayOfMonth(int day, DateTime today) {
  final base = DateTime(today.year, today.month, day);
  if (!base.isAfter(today)) {
    return base;
  }
  final prevMonth = DateTime(today.year, today.month - 1, 1);
  return DateTime(prevMonth.year, prevMonth.month, day);
}

String generateUuidV4() {
  final random = Random();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant

  String hex(int value) => value.toRadixString(16).padLeft(2, '0');

  return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}'
      '-${hex(bytes[4])}${hex(bytes[5])}'
      '-${hex(bytes[6])}${hex(bytes[7])}'
      '-${hex(bytes[8])}${hex(bytes[9])}'
      '-${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
}
