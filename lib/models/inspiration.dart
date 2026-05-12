import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'inspiration.g.dart';

// 🎨 心情类型（用字符串存储，兼容 Hive）
const List<MoodOption> moodOptions = [
  MoodOption('happy', '😊', '开心'),
  MoodOption('calm', '😌', '平静'),
  MoodOption('thoughtful', '🤔', '思考'),
  MoodOption('sad', '😢', '低落'),
  MoodOption('excited', '🤩', '兴奋'),
  MoodOption('neutral', '😐', '普通'),
];

class MoodOption {
  final String value;
  final String emoji;
  final String label;
  const MoodOption(this.value, this.emoji, this.label);
}

@HiveType(typeId: 0)
class Inspiration {
  @HiveField(0) final String id;
  @HiveField(1) final String content;
  @HiveField(2) final DateTime createdAt;
  @HiveField(3) final List<String> tags;
  @HiveField(4) final String? imagePath;
  @HiveField(5) final bool isArchived;
  @HiveField(6) final String? mood;  // 🆕 心情: 存储 moodOptions[index].value

  Inspiration({
    String? id,
    required this.content,
    DateTime? createdAt,
    this.tags = const [],
    this.imagePath,
    this.isArchived = false,
    this.mood,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Inspiration copyWith({
    String? content,
    List<String>? tags,
    String? imagePath,
    bool? isArchived,
    String? mood,
  }) {
    return Inspiration(
      id: id,
      content: content ?? this.content,
      createdAt: createdAt,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
      isArchived: isArchived ?? this.isArchived,
      mood: mood ?? this.mood,
    );
  }
  
  // 🎨 获取心情表情
  String get moodEmoji {
    final option = moodOptions.firstWhere((m) => m.value == mood, orElse: () => MoodOption('', '', ''));
    return option.emoji;
  }
  
  // 🎨 获取心情标签
  String get moodLabel {
    final option = moodOptions.firstWhere((m) => m.value == mood, orElse: () => MoodOption('', '', ''));
    return option.label;
  }
}
