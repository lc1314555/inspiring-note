import 'package:flutter/material.dart';
import '../models/inspiration.dart';
import '../utils/constants.dart';
import '../utils/platform_image.dart';
import '../screens/home/home_screen.dart' show CategoryItem, categoryItems;

class InspirationCard extends StatelessWidget {
  final Inspiration inspiration;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int? animationIndex;

  const InspirationCard({
    super.key,
    required this.inspiration,
    this.onTap,
    this.onLongPress,
    this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(HealingTheme.radiusLG),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期 + 心情行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 13, color: HealingColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(_formatDate(inspiration.createdAt),
                          style: const TextStyle(
                              color: HealingColors.textTertiary,
                              fontSize: HealingTheme.fsCaption,
                              fontWeight: HealingTheme.wMedium)),
                    ],
                  ),
                  if (inspiration.mood != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: HealingColors.accentMint.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(HealingTheme.radiusFull),
                      ),
                      child: Text(inspiration.moodEmoji, style: const TextStyle(fontSize: 14)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // 内容
              Text(
                inspiration.content,
                style: const TextStyle(
                  fontSize: HealingTheme.fsBody,
                  height: HealingTheme.lhRelaxed,
                  color: HealingColors.textPrimary,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              // 图片
              if (inspiration.imagePath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
                  child: Stack(
                    children: [
                      PlatformImage(
                        imagePath: inspiration.imagePath,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.08)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // 标签
              if (inspiration.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: inspiration.tags.take(3).map((tag) => _buildTag(tag)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // 入场动画
    if (animationIndex != null) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 300 + (animationIndex! * 50)),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildTag(String tag) {
    // 检查是否为类别标签
    final cat = categoryItems.where((c) => c.value == tag).firstOrNull;
    if (cat != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cat.gradient.map((c) => c.withOpacity(0.55)).toList(),
          ),
          borderRadius: BorderRadius.circular(HealingTheme.radiusSM),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            fontSize: HealingTheme.fsCaption,
            fontWeight: HealingTheme.wSemi,
            color: Colors.white,
          ),
        ),
      );
    }
    // 兼容旧标签
    final color = tagColorPool[tag.hashCode % tagColorPool.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(HealingTheme.radiusSM),
      ),
      child: Text(
        tag,
        style: const TextStyle(color: Colors.white, fontSize: HealingTheme.fsCaption, fontWeight: HealingTheme.wMedium),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '今天 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
