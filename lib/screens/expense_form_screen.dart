import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/tag.dart';
import '../utils/tag_utils.dart';
import '../utils/uuid.dart';
import '../widgets/tag_picker_input.dart';
import '../widgets/tag_search_dialog.dart';

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
        ? (Expense()
          ..uuid = generateUuidV4()
          ..date = _date
          ..amount = amount
          ..currency = _currency
          ..title = title
          ..tagIds = _selectedTagIds.toList())
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
    final existing = findTagByName(widget.tags, newTagName);
    final tag = existing ?? widget.onCreateTag(newTagName);
    setState(() {
      _selectedTagIds.add(tag.uuid);
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
                Expanded(child: Text(_formatDate(_date))),
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
            TagPickerInput(
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
                  for (final tag in selectedTags(
                    widget.tags,
                    _selectedTagIds,
                  ))
                    InputChip(
                      label: Text(tag.name),
                      onDeleted: () {
                        setState(() {
                          _selectedTagIds.remove(tag.uuid);
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

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
