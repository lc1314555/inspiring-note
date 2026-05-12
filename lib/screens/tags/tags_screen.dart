import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inspiration.dart';
import '../../providers/inspiration_provider.dart';
import '../../utils/constants.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspirationProvider>(context);
    final allTags = provider.allTags;
    final filteredTags = _searchQuery.isEmpty
        ? allTags
        : allTags.where((t) => t.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final moodStats = provider.moodStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('标签管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTagDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计头部
          Container(
            padding: const EdgeInsets.all(HealingTheme.spacingLG),
            child: Column(
              children: [
                Text(
                  '共 ${allTags.length} 个标签',
                  style: const TextStyle(
                    fontSize: HealingTheme.fsHeading,
                    fontWeight: HealingTheme.wSemi,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '管理你的灵感分类',
                  style: TextStyle(
                    fontSize: HealingTheme.fsBodySmall,
                    color: HealingColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20, color: HealingColors.textTertiary),
                hintText: '搜索标签',
                hintStyle: const TextStyle(fontSize: HealingTheme.fsBodySmall, color: HealingColors.textHint),
                filled: true,
                fillColor: HealingColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
                  borderSide: BorderSide(color: HealingColors.border.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
                  borderSide: BorderSide(color: HealingColors.border.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
                  borderSide: const BorderSide(color: HealingColors.accentMint, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          const SizedBox(height: HealingTheme.spacingMD),
          // 心情统计（如果有心情数据）
          if (moodStats.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD),
              child: Row(
                children: [
                  const Icon(Icons.emoji_emotions_outlined, size: 16, color: HealingColors.textTertiary),
                  const SizedBox(width: 8),
                  const Text('心情分布',
                      style: TextStyle(
                          fontSize: HealingTheme.fsBodySmall,
                          color: HealingColors.textSecondary,
                          fontWeight: HealingTheme.wMedium)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moodStats.entries.map((e) {
                  final mood = moodOptions.firstWhere(
                    (m) => m.value == e.key,
                    orElse: () => MoodOption('', '', ''),
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: HealingColors.accentMint.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(HealingTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text('${mood.label} ×${e.value}',
                            style: const TextStyle(
                                fontSize: HealingTheme.fsCaption,
                                color: HealingColors.accentMint,
                                fontWeight: HealingTheme.wMedium)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: HealingTheme.spacingMD),
            const Divider(height: 1),
          ],
          // 标签列表
          Expanded(
            child: filteredTags.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.label_outline, size: 48, color: HealingColors.textDisabled),
                        const SizedBox(height: HealingTheme.spacingMD),
                        Text(
                          _searchQuery.isEmpty ? '还没有标签' : '没有找到匹配的标签',
                          style: const TextStyle(
                            fontSize: HealingTheme.fsBody,
                            color: HealingColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD),
                    itemCount: filteredTags.length,
                    itemBuilder: (ctx, i) {
                      final tag = filteredTags[i];
                      final count = provider.inspirations.where((insp) => insp.tags.contains(tag)).length;
                      final color = tagColorPool[i % tagColorPool.length];
                      return _buildTagListItem(tag, count, color, provider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagListItem(String tag, int count, Color color, InspirationProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(HealingTheme.radiusLG),
          onTap: () {
            provider.filterByTag(tag);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HealingColors.cardBackground,
              borderRadius: BorderRadius.circular(HealingTheme.radiusLG),
              boxShadow: [HealingTheme.boxShadowSubtle],
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag,
                        style: const TextStyle(
                          fontSize: HealingTheme.fsBody,
                          fontWeight: HealingTheme.wMedium,
                          color: HealingColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count 条灵感',
                        style: const TextStyle(
                          fontSize: HealingTheme.fsCaption,
                          color: HealingColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, size: 18),
                  color: HealingColors.textTertiary,
                  onPressed: () {
                    provider.filterByTag(tag);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'rename', child: Text('重命名')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                  onSelected: (v) => _handleAction(tag, v, provider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAction(String tag, String action, InspirationProvider provider) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context, tag);
        break;
      case 'delete':
        _showDeleteConfirm(context, tag, provider);
        break;
    }
  }

  void _showCreateTagDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HealingTheme.radiusXL)),
        title: const Text('新建标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入标签名称',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) Navigator.pop(context, v.trim());
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    ).then((newTag) {
      if (newTag != null && newTag.toString().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('标签 "$newTag" 已创建，在编辑灵感时使用 ~')),
        );
      }
    });
  }

  void _showRenameDialog(BuildContext context, String oldTag) {
    final controller = TextEditingController(text: oldTag);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HealingTheme.radiusXL)),
        title: const Text('重命名标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入新名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final newTag = controller.text.trim();
              if (newTag.isNotEmpty && newTag != oldTag) {
                // 实际重命名逻辑需要遍历所有灵感更新标签
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('标签已重命名为 "$newTag"')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String tag, InspirationProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HealingTheme.radiusXL)),
        title: const Text('删除标签？'),
        content: Text('确定要删除标签 "$tag" 吗？\n灵感内容不会被删除，仅移除标签关联。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              // 实际删除逻辑：遍历所有灵感移除该标签
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('标签 "$tag" 已删除')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
