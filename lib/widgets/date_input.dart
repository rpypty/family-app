import 'package:flutter/material.dart';

class DateInput extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const DateInput({
    super.key,
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
