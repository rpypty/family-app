import 'package:flutter/material.dart';

class TagPickerInput extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const TagPickerInput({super.key, required this.label, required this.onTap});

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
