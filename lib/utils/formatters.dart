import '../models/expense.dart';

String formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String formatAmount(double amount) {
  return amount.toStringAsFixed(2);
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

String formatPercent(double value, double total) {
  if (total <= 0) return '0';
  return ((value / total) * 100).toStringAsFixed(0);
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime latestDayOfMonth(int day, DateTime today) {
  final base = DateTime(today.year, today.month, day);
  if (!base.isAfter(today)) {
    return base;
  }
  final prevMonth = DateTime(today.year, today.month - 1, 1);
  return DateTime(prevMonth.year, prevMonth.month, day);
}

Map<String, double> aggregateByCurrency(List<Expense> expenses) {
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
