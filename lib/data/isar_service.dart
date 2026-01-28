import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import '../models/settings.dart';
import '../models/tag.dart';

Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [ExpenseSchema, TagSchema, SettingsSchema],
    directory: dir.path,
  );
}
