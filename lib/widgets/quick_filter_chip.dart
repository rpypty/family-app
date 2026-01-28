import 'package:flutter/material.dart';

class QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QuickFilterChip({super.key, required this.label, required this.onTap});

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
