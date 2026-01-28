import '../models/expense.dart';

Map<String, double> aggregateByTag(List<Expense> expenses) {
  final totals = <String, double>{};
  for (final expense in expenses) {
    for (final tagId in expense.tagIds) {
      totals.update(
        tagId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
  }
  return totals;
}

Map<DateTime, double> groupByMonth(List<Expense> expenses) {
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

double? percentChange(double previous, double current) {
  if (previous == 0) return null;
  return ((current - previous) / previous) * 100;
}
