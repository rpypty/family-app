import 'package:isar/isar.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;
  late String uuid;
  late String name;
}
