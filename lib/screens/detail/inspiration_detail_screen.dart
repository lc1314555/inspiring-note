import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/inspiration.dart';
import '../../utils/constants.dart';
import '../../utils/platform_image.dart';
import '../../widgets/healing_background.dart';
import '../home/home_screen.dart' show categoryItems;
import '../editor/editor_screen.dart';

class InspirationDetailScreen extends StatelessWidget {
  final Inspiration inspiration;
  const InspirationDetailScreen({super.key, required this.inspiration});

  String get _categoryTag {
    for (final tag in inspiration.tags) {
      if (categoryItems.any((c) => c.value == tag)) return tag;
    }
    return '';
  }

  Color get _categoryAccent {
    switch (_categoryTag) {
      case '灵感火花': return const Color(0xFFFF9E5E);
      case '今日印记': return const Color(0xFF5EC4A0);
      case '真实情绪': return const Color(0xFF9F8FD5);
      default: return HealingColors.accentMint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HealingBackground(
        child: SafeArea(
          child: CustomScrollView(
        slivers: [
          // 顶部图片/标题栏
          if (inspiration.imagePath != null)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PlatformImage(
                      imagePath: inspiration.imagePath,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              HealingColors.backgroundWarm.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 操作栏
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: HealingColors.cardBackground.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HealingColors.cardBackground.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, size: 20),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, __) => EditorScreen(inspiration: inspiration),
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder: (_, a, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                          child: FadeTransition(opacity: a, child: child),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          // 心情徽章
          if (inspiration.mood != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(HealingTheme.spacingMD, 4, HealingTheme.spacingMD, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: HealingColors.accentMint.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(HealingTheme.radiusFull),
                      ),
                      child: Row(
                        children: [
                          Text(inspiration.moodEmoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            inspiration.moodLabel,
                            style: const TextStyle(
                              fontSize: HealingTheme.fsBodySmall,
                              color: HealingColors.accentMint,
                              fontWeight: HealingTheme.wMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 时间戳
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(HealingTheme.spacingMD, 12, HealingTheme.spacingMD, 0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: HealingColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    _formatFullDate(inspiration.createdAt),
                    style: const TextStyle(
                      fontSize: HealingTheme.fsCaption,
                      color: HealingColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 正文
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(HealingTheme.spacingMD, 24, HealingTheme.spacingMD, 20),
            sliver: SliverToBoxAdapter(
              child: Text(
                inspiration.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: HealingColors.textPrimary,
                ),
              ),
            ),
          ),
          // 标签
          if (inspiration.tags.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(HealingTheme.spacingMD, 0, HealingTheme.spacingMD, 32),
              sliver: SliverToBoxAdapter(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: inspiration.tags.map(_buildTag).toList(),
                ),
              ),
            ),
          // 底部操作栏
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(HealingTheme.spacingMD, 0, HealingTheme.spacingMD, 48),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _actionButton(Icons.copy_outlined, '复制', () => _copyContent(context)),
                  const SizedBox(width: 12),
                  _actionButton(Icons.share_outlined, '分享', () => _share(context)),
                  const SizedBox(width: 12),
                  _actionButton(
                    inspiration.isArchived ? Icons.bookmark : Icons.bookmark_border,
                    inspiration.isArchived ? '已归档' : '归档',
                    () => _toggleArchive(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    final cat = categoryItems.where((c) => c.value == tag).firstOrNull;
    if (cat != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cat.gradient,
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
    final color = tagColorPool[tag.hashCode % tagColorPool.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(HealingTheme.radiusSM),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: color,
          fontSize: HealingTheme.fsCaption,
          fontWeight: HealingTheme.wMedium,
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: HealingColors.cardBackground.withOpacity(0.7),
            borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
            border: Border.all(color: HealingColors.border.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: HealingColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: HealingTheme.fsCaption,
                  color: HealingColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'copy':
        _copyContent(context);
        break;
      case 'archive':
        _toggleArchive(context);
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _copyContent(BuildContext context) {
    Clipboard.setData(ClipboardData(text: inspiration.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板 📋'), duration: Duration(seconds: 2)),
    );
  }

  void _share(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中 ~'), duration: Duration(seconds: 2)),
    );
  }

  void _toggleArchive(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(inspiration.isArchived ? '已取消归档' : '已归档 📦'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HealingTheme.radiusXL)),
        title: const Text('确认删除？'),
        content: const Text('删除后无法恢复，确定要放下这份灵感吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // detail
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已删除 🍃'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
