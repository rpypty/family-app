import '../models/tag.dart';

List<Tag> selectedTags(List<Tag> tags, Set<String> selectedIds) {
  return tags.where((tag) => selectedIds.contains(tag.uuid)).toList();
}

Tag? findTagByName(List<Tag> tags, String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  for (final tag in tags) {
    if (tag.name.toLowerCase() == normalized) {
      return tag;
    }
  }
  return null;
}

String pluralTag(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) return 'тег';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'тега';
  }
  return 'тегов';
}
