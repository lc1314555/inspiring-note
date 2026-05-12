import 'package:flutter/foundation.dart';
import '../models/inspiration.dart';
import '../services/hive_service.dart';

// 日期过滤模式
enum DateFilterMode {
  all,       // 全部
  today,     // 今天
  week,      // 本周
  month,     // 本月
  custom,    // 自定义日期范围
}

class InspirationProvider extends ChangeNotifier {
  List<Inspiration> _inspirations = [];
  List<Inspiration> _filtered = [];
  String? _selectedTag;
  String? _selectedMood;
  String _searchQuery = '';
  DateFilterMode _dateFilterMode = DateFilterMode.all;
  DateTime? _customDateStart;
  DateTime? _customDateEnd;

  List<Inspiration> get inspirations => _filtered;
  String? get selectedTag => _selectedTag;
  String? get selectedMood => _selectedMood;
  String get searchQuery => _searchQuery;
  DateFilterMode get dateFilterMode => _dateFilterMode;
  DateTime? get customDateStart => _customDateStart;
  DateTime? get customDateEnd => _customDateEnd;

  Future<void> load() async {
    _inspirations = HiveService.getAll();
    _applyFilters();
    notifyListeners();
  }

  Future<void> add(Inspiration inspiration) async {
    await HiveService.add(inspiration);
    await load();
  }

  Future<void> update(Inspiration inspiration) async {
    await HiveService.update(inspiration);
    await load();
  }

  Future<void> delete(String id) async {
    await HiveService.delete(id);
    await load();
  }

  void filterByTag(String? tag) {
    _selectedTag = tag;
    // 切换到非真实情绪标签时清除心情过滤
    if (tag != '真实情绪') {
      _selectedMood = null;
    }
    _applyFilters();
    notifyListeners();
  }

  // 🆕 心情过滤
  void filterByMood(String? mood) {
    _selectedMood = mood;
    _applyFilters();
    notifyListeners();
  }

  // 清除所有过滤
  void clearFilters() {
    _selectedTag = null;
    _selectedMood = null;
    _searchQuery = '';
    _dateFilterMode = DateFilterMode.all;
    _customDateStart = null;
    _customDateEnd = null;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByDate(DateFilterMode mode, {DateTime? start, DateTime? end}) {
    _dateFilterMode = mode;
    _customDateStart = start;
    _customDateEnd = end;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = _inspirations;

    // 标签过滤
    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      result = result.where((i) => i.tags.contains(_selectedTag)).toList();
    }

    // 心情过滤
    if (_selectedMood != null && _selectedMood!.isNotEmpty) {
      result = result.where((i) => i.mood == _selectedMood).toList();
    }

    // 日期过滤
    final now = DateTime.now();
    switch (_dateFilterMode) {
      case DateFilterMode.today:
        result = result.where((i) {
          return i.createdAt.year == now.year &&
              i.createdAt.month == now.month &&
              i.createdAt.day == now.day;
        }).toList();
        break;
      case DateFilterMode.week:
        final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1);
        final weekEnd = weekStart.add(const Duration(days: 7));
        result = result.where((i) => i.createdAt.isAfter(weekStart) && i.createdAt.isBefore(weekEnd)).toList();
        break;
      case DateFilterMode.month:
        result = result.where((i) {
          return i.createdAt.year == now.year && i.createdAt.month == now.month;
        }).toList();
        break;
      case DateFilterMode.custom:
        if (_customDateStart != null) {
          final end = _customDateEnd ?? _customDateStart!;
          final startDay = DateTime(_customDateStart!.year, _customDateStart!.month, _customDateStart!.day);
          final endDay = DateTime(end.year, end.month, end.day).add(const Duration(days: 1));
          result = result.where((i) => i.createdAt.isAfter(startDay.subtract(const Duration(seconds: 1))) && i.createdAt.isBefore(endDay)).toList();
        }
        break;
      case DateFilterMode.all:
        break;
    }

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((i) =>
        i.content.toLowerCase().contains(q) ||
        i.tags.any((t) => t.toLowerCase().contains(q))
      ).toList();
    }

    _filtered = result;
  }

  List<String> get allTags => HiveService.getAllTags();

  // 搜索返回结果（不修改状态）
  List<Inspiration> searchResults(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _inspirations.where((i) =>
      i.content.toLowerCase().contains(q) ||
      i.tags.any((t) => t.toLowerCase().contains(q))
    ).toList();
  }
  
  // 🆕 获取所有已使用的心情
  List<String> get usedMoods {
    final moods = <String>{};
    for (final item in _inspirations) {
      if (item.mood != null) moods.add(item.mood!);
    }
    return moods.toList();
  }
  
  // 🆕 获取心情对应的灵感数量
  Map<String, int> get moodStats {
    final stats = <String, int>{};
    for (final item in _inspirations) {
      if (item.mood != null) {
        stats[item.mood!] = (stats[item.mood!] ?? 0) + 1;
      }
    }
    return stats;
  }
}
