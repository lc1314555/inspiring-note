import 'package:flutter/material.dart';

// 🎨 治愈系配色（默认暖米白主题）
class HealingColors {
  // 基础色
  static const Color backgroundWarm = Color(0xFFF8F5F2);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF999999);
  static const Color accentMint = Color(0xFFA8D5BA);
  static const Color accentPink = Color(0xFFD4A5C3);
  static const Color accentLavender = Color(0xFF90C5EE);
  // 扩展色
  static const Color textTertiary = Color(0xFFAAAAAA);
  static const Color textHint = Color(0xFFC8C0B8);
  static const Color surfaceElevated = Color(0xFFFAFAFA);
  static const Color border = Color(0xFFE8E0D8);
  static const Color shadowTint = Color(0x0FA8D5BA);
  static const Color accentSecondary = Color(0xFFD4A5C3);
  static const Color success = Color(0xFFB8D8BE);
  static const Color warning = Color(0xFFE8C5A8);
  static const Color error = Color(0xFFE8B4B8);
}

// 🎨 多套治愈风主题配色
class HealingThemes {
  static const ThemeConfig warm = ThemeConfig(
    name: '暖米白',
    background: [Color(0xFFF8F5F2), Color(0xFFF0E6D3), Color(0xFFE8DCC4)],
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF333333),
    textSecondary: Color(0xFF666666),
    accent: Color(0xFFA8D5BA),
    particleColors: [Color(0xFFA8D5BA), Color(0xFFE8C5A8), Color(0xFFD4A5C3)],
  );

  static const ThemeConfig cool = ThemeConfig(
    name: '淡雾蓝',
    background: [Color(0xFFF0F4F8), Color(0xFFE6EEF4), Color(0xFFDDE6ED)],
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2C3E50),
    textSecondary: Color(0xFF5A6B7C),
    accent: Color(0xFF7FB8DA),
    particleColors: [Color(0xFF7FB8DA), Color(0xFFA8C5E8), Color(0xFFB8D8E8)],
  );

  static const ThemeConfig sunset = ThemeConfig(
    name: '暮光橙',
    background: [Color(0xFFFFF5E6), Color(0xFFFFEBD6), Color(0xFFE8D5C4)],
    card: Color(0xFFFFFDF9),
    textPrimary: Color(0xFF4A3728),
    textSecondary: Color(0xFF7A6350),
    accent: Color(0xFFFFB87F),
    particleColors: [Color(0xFFFFB87F), Color(0xFFFFD5A8), Color(0xFFE8B8A8)],
  );

  static const ThemeConfig forest = ThemeConfig(
    name: '森林绿',
    background: [Color(0xFFE8F4E8), Color(0xFFDCE8DC), Color(0xFFC8D8C8)],
    card: Color(0xFFF8FFF8),
    textPrimary: Color(0xFF283C28),
    textSecondary: Color(0xFF4A5C4A),
    accent: Color(0xFF8FC88F),
    particleColors: [Color(0xFF8FC88F), Color(0xFFB8E8B8), Color(0xFFA8D5A8)],
  );

  static const ThemeConfig lavender = ThemeConfig(
    name: '薰衣草紫',
    background: [Color(0xFFF5F0F8), Color(0xFFEBE6F0), Color(0xFFE0D8E8)],
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF3C2C4A),
    textSecondary: Color(0xFF6A5A7C),
    accent: Color(0xFFB89FD5),
    particleColors: [Color(0xFFB89FD5), Color(0xFFD4C5E8), Color(0xFFC5B8E8)],
  );

  static List<ThemeConfig> get all => [warm, cool, sunset, forest, lavender];
}

class ThemeConfig {
  final String name;
  final List<Color> background;
  final Color card, textPrimary, textSecondary, accent;
  final List<Color> particleColors;

  const ThemeConfig({
    required this.name,
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.particleColors,
  });
}

// 🎨 标签颜色池（莫兰迪色系）
const List<Color> tagColorPool = [
  Color(0xFFA8D5BA), Color(0xFFB8C5E8), Color(0xFFD4A5C3),
  Color(0xFFE8C5A8), Color(0xFFB8D8BE), Color(0xFFC5B8E8),
  Color(0xFFA8C5D5), Color(0xFFD5B8C5), Color(0xFFC5D5A8),
];

// 🎵 白噪声选项
const List<NoiseOption> noiseOptions = [
  NoiseOption('rain', '🌧️', '雨声'),
  NoiseOption('ocean', '🌊', '海浪'),
  NoiseOption('forest', '🌲', '森林'),
  NoiseOption('cafe', '☕', '咖啡馆'),
  NoiseOption('wind', '🍃', '微风'),
];

class NoiseOption {
  final String value, emoji, label;
  const NoiseOption(this.value, this.emoji, this.label);
}

// 💬 治愈文案库
const List<String> healingQuotes = [
  "每一缕灵感，都值得被温柔收藏 🌿",
  "慢慢来，比较快 ✨",
  "今天的你，也很棒呀 🌸",
  "记录，是为了更好地遇见自己 💫",
  "小确幸，藏在日常的缝隙里 🍃",
  "心若向阳，无畏悲伤 🌻",
  "温柔半两，从容一生 🕊️",
  "生活明朗，万物可爱 🌈",
];

// 🎨 视觉规范
class HealingTheme {
  // 字体比例
  static const double fsCaption = 11.0;
  static const double fsBodySmall = 13.0;
  static const double fsBody = 15.0;
  static const double fsBodyLarge = 17.0;
  static const double fsHeading = 20.0;
  static const double fsDisplay = 24.0;

  // 字重
  static const FontWeight wRegular = FontWeight.w400;
  static const FontWeight wMedium = FontWeight.w500;
  static const FontWeight wSemi = FontWeight.w600;
  static const FontWeight wBold = FontWeight.w700;

  // 行高
  static const double lhTight = 1.2;
  static const double lhNormal = 1.5;
  static const double lhRelaxed = 1.7;
  static const double lhQuotes = 1.8;

  // 间距
  static const double spacingXXS = 2.0;
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // 圆角
  static const double radiusXS = 6.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 999.0;

  // 阴影
  static const boxShadowSubtle = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.04),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const boxShadowCard = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.06),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const boxShadowElevated = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.10),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const boxShadowGlow = BoxShadow(
    color: Color.fromRGBO(168, 213, 186, 0.25),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  // 动画
  static const Duration animationFast = Duration(milliseconds: 100);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationSlow = Duration(milliseconds: 400);
}
