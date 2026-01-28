import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/expense.dart';
import '../models/tag.dart';
import '../screens/analytics_screen.dart';
import '../screens/expense_form_screen.dart';
import '../screens/reports_screen.dart';
import '../utils/tag_utils.dart';
import '../utils/uuid.dart';
import '../widgets/expense_list_view.dart';

class HomeScreen extends StatefulWidget {
  final Isar isar;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isar,
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (await widget.isar.expenses.count() == 0) {
      await _seedMockData();
    }

    final tags = await widget.isar.tags.where().findAll();
    final expenses = await widget.isar.expenses.where().findAll();
    setState(() {
      _tags
        ..clear()
        ..addAll(tags);
      _expenses
        ..clear()
        ..addAll(expenses);
      _loading = false;
    });
  }

  Future<void> _seedMockData() async {
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
        Tag()
          ..uuid = generateUuidV4()
          ..name = name,
    ];

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

    final today = DateTime.now();
    final daysToGenerate = 420; // чтобы был прошлый год + текущий
    final targetCount = 500;
    var added = 0;

    final expenses = <Expense>[];

    for (var i = 0; i < daysToGenerate && added < targetCount; i++) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final perDay = 1 + random.nextInt(4); // 1-4 записей в день
      for (var j = 0; j < perDay && added < targetCount; j++) {
        final tagCount = 1 + random.nextInt(2);
        final picked = <Tag>{};
        while (picked.length < tagCount) {
          picked.add(tags[random.nextInt(tags.length)]);
        }

        final amount = (5 + random.nextInt(150)) + random.nextDouble();
        expenses.add(
          Expense()
            ..uuid = generateUuidV4()
            ..date = day
            ..amount = double.parse(amount.toStringAsFixed(2))
            ..currency = 'BYN'
            ..title = titles[random.nextInt(titles.length)]
            ..tagIds = picked.map((tag) => tag.uuid).toList(),
        );
        added++;
      }
    }

    expenses.addAll([
      Expense()
        ..uuid = generateUuidV4()
        ..date = DateTime(today.year, today.month, today.day)
        ..amount = 12.40
        ..currency = 'BYN'
        ..title = 'Сегодня: кофе'
        ..tagIds = [tags[0].uuid],
      Expense()
        ..uuid = generateUuidV4()
        ..date = DateTime(today.year, today.month, today.day)
            .subtract(const Duration(days: 1))
        ..amount = 28.30
        ..currency = 'BYN'
        ..title = 'Вчера: такси'
        ..tagIds = [tags[1].uuid],
    ]);

    await widget.isar.writeTxn(() async {
      await widget.isar.tags.putAll(tags);
      await widget.isar.expenses.putAll(expenses);
    });
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
      await _saveExpense(result.expense!);
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
      await _deleteExpense(expense);
      setState(() {
        _expenses.removeWhere((e) => e.uuid == expense.uuid);
      });
      return;
    }

    if (result.action == ExpenseFormAction.save && result.expense != null) {
      await _saveExpense(result.expense!);
      setState(() {
        final index = _expenses.indexWhere((e) => e.uuid == expense.uuid);
        if (index >= 0) {
          _expenses[index] = result.expense!;
        }
      });
    }
  }

  Tag _createTag(String name) {
    final existing = findTagByName(_tags, name);
    if (existing != null) return existing;
    final tag = Tag()
      ..uuid = generateUuidV4()
      ..name = name;
    setState(() {
      _tags.add(tag);
    });
    _saveTag(tag);
    return tag;
  }

  Future<void> _saveTag(Tag tag) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.tags.put(tag);
    });
  }

  Future<void> _saveExpense(Expense expense) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.expenses.put(expense);
    });
  }

  Future<void> _deleteExpense(Expense expense) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.expenses.delete(expense.id);
    });
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
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
      floatingActionButton: (!_loading && _currentIndex == 0)
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
