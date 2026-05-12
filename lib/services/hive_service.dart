import 'package:hive_flutter/hive_flutter.dart';
import '../models/inspiration.dart';

class HiveService {
  static const String boxName = 'inspirations';
  static late Box<Inspiration> _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(InspirationAdapter());
    _box = await Hive.openBox<Inspiration>(boxName);
  }

  static Box<Inspiration> get box => _box;

  static Future<void> add(Inspiration inspiration) async {
    await _box.put(inspiration.id, inspiration);
  }

  static Future<void> update(Inspiration inspiration) async {
    await _box.put(inspiration.id, inspiration);
  }

  static Future<void> delete(String id) async {
    await _box.delete(id);
  }

  static List<Inspiration> getAll({bool includeArchived = false}) {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return includeArchived ? items : items.where((i) => !i.isArchived).toList();
  }

  static List<Inspiration> getByTag(String tag) {
    return getAll().where((i) => i.tags.contains(tag)).toList();
  }

  static List<String> getAllTags() {
    final tags = <String>{};
    for (final item in getAll()) {
      tags.addAll(item.tags);
    }
    return tags.toList()..sort();
  }

  static Future<void> close() async {
    await _box.close();
  }
}
