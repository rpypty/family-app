import 'package:flutter/material.dart';

import '../utils/tag_utils.dart';

class TagRow extends StatelessWidget {
  final List<String> tagNames;
  final int maxVisible;
  final VoidCallback? onShowAll;

  const TagRow({
    super.key,
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
                'еще $remaining ${pluralTag(remaining)}',
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

void showAllTags(BuildContext context, List<String> tagNames) {
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
