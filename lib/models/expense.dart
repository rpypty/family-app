import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;
  late String uuid;
  late DateTime date;
  late double amount;
  late String currency;
  late String title;
  late List<String> tagIds;

  Expense copyWith({
    DateTime? date,
    double? amount,
    String? currency,
    String? title,
    List<String>? tagIds,
  }) {
    return Expense()
      ..id = id
      ..uuid = uuid
      ..date = date ?? this.date
      ..amount = amount ?? this.amount
      ..currency = currency ?? this.currency
      ..title = title ?? this.title
      ..tagIds = tagIds ?? this.tagIds;
  }
}
