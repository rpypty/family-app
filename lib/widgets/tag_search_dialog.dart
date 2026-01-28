import 'package:flutter/material.dart';

import '../models/tag.dart';
import '../utils/tag_utils.dart';

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
                                      final existing = findTagByName(tags, name);
                                      final tag = existing ?? onCreateTag(name);
                                      selected.add(tag.uuid);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add),
                                    label: Text('Добавить тег "$query"'),
                                  ),
                                ),
                            ],
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final tag = filtered[index];
                              final isSelected = selected.contains(tag.uuid);
                              return CheckboxListTile(
                                value: isSelected,
                                dense: true,
                                title: Text(tag.name),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selected.add(tag.uuid);
                                    } else {
                                      selected.remove(tag.uuid);
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
