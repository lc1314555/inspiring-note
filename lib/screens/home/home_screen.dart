import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inspiration.dart';
import '../../providers/inspiration_provider.dart';
import '../../widgets/inspiration_card.dart';
import '../../utils/constants.dart';
import '../../widgets/healing_background.dart';
import '../editor/editor_screen.dart';
import '../detail/inspiration_detail_screen.dart';
import '../settings/settings_screen.dart';

// 🏷️ 三大标签类别
const List<CategoryItem> categoryItems = [
  CategoryItem(
    value: '灵感火花',
    icon: '💡',
    label: '灵感火花',
    gradient: [Color(0xFFFFE8A8), Color(0xFFFFD07F)],
  ),
  CategoryItem(
    value: '今日印记',
    icon: '📸',
    label: '今日印记',
    gradient: [Color(0xFFB8E8D0), Color(0xFF7FC8A8)],
  ),
  CategoryItem(
    value: '真实情绪',
    icon: '🌊',
    label: '真实情绪',
    gradient: [Color(0xFFC5B8E8), Color(0xFF9F8FD5)],
  ),
];

class CategoryItem {
  final String value, icon, label;
  final List<Color> gradient;
  const CategoryItem({
    required this.value,
    required this.icon,
    required this.label,
    required this.gradient,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  String _getCategoryLabel(String? tag) {
    switch (tag) {
      case '灵感火花': return '记录灵感';
      case '今日印记': return '记录点滴';
      case '真实情绪': return '记录情绪';
      default: return '记录';
    }
  }

  IconData _getCategoryIcon(String? tag) {
    switch (tag) {
      case '灵感火花': return Icons.lightbulb;
      case '今日印记': return Icons.camera_alt_outlined;
      case '真实情绪': return Icons.favorite_outline;
      default: return Icons.add;
    }
  }

  Color _getCategoryAccent(String? tag) {
    switch (tag) {
      case '灵感火花': return const Color(0xFFFFB87F);
      case '今日印记': return const Color(0xFF7FC8A8);
      case '真实情绪': return const Color(0xFF9F8FD5);
      default: return HealingColors.accentMint;
    }
  }

  bool _shouldShowFab(InspirationProvider provider) {
    // "真实情绪"下只有"全部"（未选中子情绪）时显示
    if (provider.selectedTag == '真实情绪') {
      return provider.selectedMood == null;
    }
    return provider.selectedTag != null;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspirationProvider>(context);
    final quote = healingQuotes[DateTime.now().day % healingQuotes.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('心流屋'),
        actions: [
          // 白噪声开关
          StatefulBuilder(
            builder: (ctx, setSt) => IconButton(
              icon: Icon(
                WhiteNoisePlayer.isPlaying ? Icons.volume_up : Icons.volume_off,
                color: WhiteNoisePlayer.isPlaying ? HealingColors.accentMint : HealingColors.textSecondary,
              ),
              onPressed: () {
                try {
                  if (WhiteNoisePlayer.isPlaying) {
                    WhiteNoisePlayer.stop();
                    if (mounted && ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('🔇 白噪声已停止'), duration: Duration(seconds: 1)),
                      );
                    }
                  } else {
                    final sound = WhiteNoisePlayer.preferredSound;
                    WhiteNoisePlayer.play(sound);
                    final label = sound == 'stream' ? '🌊 溪流声' : '🌧️ 雨声';
                    if (mounted && ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('$label播放中'), duration: const Duration(seconds: 2)),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted && ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('音频播放失败: $e'), duration: const Duration(seconds: 2)),
                    );
                  }
                }
                setSt(() {});
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: HealingColors.textSecondary),
            onPressed: () => _showSearch(context, provider),
          ),
          // 日期过滤按钮
          IconButton(
            icon: Icon(
              provider.dateFilterMode != DateFilterMode.all
                  ? Icons.calendar_today
                  : Icons.calendar_today_outlined,
              color: provider.dateFilterMode != DateFilterMode.all
                  ? HealingColors.accentMint
                  : HealingColors.textSecondary,
            ),
            onPressed: () => _showDateFilter(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: HealingColors.textSecondary),
            onPressed: () => Navigator.push(context, PageRouteBuilder(
              pageBuilder: (_, a, __) => const SettingsScreen(),
              transitionDuration: const Duration(milliseconds: 250),
              transitionsBuilder: (_, a, __, child) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                child: child,
              ),
            )),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 语录横幅
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(HealingTheme.spacingMD, HealingTheme.spacingSM, HealingTheme.spacingMD, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HealingColors.cardBackground.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(HealingTheme.radiusXL),
                  border: Border.all(color: HealingColors.accentMint.withOpacity(0.2)),
                  boxShadow: [HealingTheme.boxShadowSubtle],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: HealingColors.accentMint.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.format_quote, color: HealingColors.accentMint, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote,
                            style: const TextStyle(
                              fontSize: HealingTheme.fsBodySmall,
                              height: HealingTheme.lhQuotes,
                              color: HealingColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text('今日幸运签',
                              style: TextStyle(
                                  fontSize: HealingTheme.fsCaption,
                                  color: HealingColors.textTertiary,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: HealingTheme.spacingSM)),
          // 类别过滤行
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD),
                children: [
                  ...categoryItems.map((cat) {
                    final accent = _getCategoryAccent(cat.value);
                    return _buildFilterChip(cat.label, accent, provider.selectedTag == cat.value, () => provider.filterByTag(cat.value));
                  }),
                  _buildFilterChip('全部', HealingColors.accentLavender, provider.selectedTag == null, () => provider.filterByTag(null)),
                ],
              ),
            ),
          ),
          // 真实情绪 - 情绪子分类
          if (provider.selectedTag == '真实情绪') ...[
            const SliverToBoxAdapter(child: SizedBox(height: 6)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD),
                  children: [
                    _buildMoodChip('全部', null, provider.selectedMood == null, () => provider.filterByMood(null)),
                    ...moodOptions.map((mood) => _buildMoodChip(
                      '${mood.emoji} ${mood.label}',
                      mood.value,
                      provider.selectedMood == mood.value,
                      () => provider.filterByMood(mood.value),
                    )),
                  ],
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: HealingTheme.spacingSM)),
          // 列表头部
          if (provider.inspirations.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD),
              sliver: SliverToBoxAdapter(
                child: Text('共 ${provider.inspirations.length} 条灵感',
                    style: const TextStyle(
                        fontSize: HealingTheme.fsCaption,
                        color: HealingColors.textTertiary,
                        fontWeight: HealingTheme.wMedium)),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: HealingTheme.spacingXS)),
          // 卡片列表或空状态
          provider.inspirations.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState(provider.selectedTag))
              : SliverPadding(
                  padding: const EdgeInsets.only(bottom: 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => InspirationCard(
                        inspiration: provider.inspirations[i],
                        animationIndex: i,
                        onTap: () => _showDetail(provider.inspirations[i]),
                        onLongPress: () => _showActions(provider, provider.inspirations[i]),
                      ),
                      childCount: provider.inspirations.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: _shouldShowFab(provider)
          ? FloatingActionButton.extended(
        onPressed: () {
          final selectedCategory = provider.selectedTag;
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => EditorScreen(category: selectedCategory),
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 250),
              transitionsBuilder: (_, a, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
                      .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                  child: FadeTransition(opacity: a, child: child),
                );
              },
            ),
          );
        },
        backgroundColor: _getCategoryAccent(provider.selectedTag),
        icon: Icon(_getCategoryIcon(provider.selectedTag), color: Colors.white, size: 20),
        label: Text(_getCategoryLabel(provider.selectedTag),
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      )
          : null,
    );
  }

  Widget _buildFilterChip(String label, Color accentColor, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: HealingTheme.animationNormal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(HealingTheme.radiusFull),
            border: Border.all(
              color: isSelected ? accentColor : HealingColors.border,
              width: 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(color: accentColor.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
            ] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.check, size: 12, color: Colors.white),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: HealingTheme.fsCaption,
                  fontWeight: HealingTheme.wMedium,
                  color: isSelected ? Colors.white : HealingColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChip(String label, String? mood, bool isSelected, VoidCallback onTap) {
    final moodColor = _getCategoryAccent('真实情绪');
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: HealingTheme.animationNormal,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? moodColor : Colors.transparent,
            borderRadius: BorderRadius.circular(HealingTheme.radiusFull),
            border: Border.all(
              color: isSelected ? moodColor : HealingColors.border,
              width: 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(color: moodColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
            ] : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? HealingTheme.wMedium : FontWeight.normal,
              color: isSelected ? Colors.white : HealingColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? tag) {
    String title;
    String subtitle;
    String hint;
    IconData icon;

    switch (tag) {
      case '灵感火花':
        title = '还没有灵感';
        subtitle = '每一个闪光的想法都值得被记录';
        hint = '捕捉那一闪而过的念头 ✨';
        icon = Icons.lightbulb;
        break;
      case '今日印记':
        title = '还没有记录';
        subtitle = '生活中的小片段也值得珍藏';
        hint = '拍下今天的一个瞬间 📸';
        icon = Icons.camera_alt_outlined;
        break;
      case '真实情绪':
        title = '还没有记录';
        subtitle = '每一种情绪都值得被安放';
        hint = '深呼吸，感受此刻的感受 🌊';
        icon = Icons.favorite_outline;
        break;
      default:
        title = '还没有灵感';
        subtitle = '每一次闪光都值得被记录';
        hint = '慢慢来，灵感会在不经意间出现 ✨';
        icon = Icons.lightbulb;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (ctx, child) {
              return Transform.scale(
                scale: 1.0 + _pulseController.value * 0.06,
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _getCategoryAccent(tag).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 56, color: _getCategoryAccent(tag).withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: HealingTheme.spacingLG),
          Text(
            title,
            style: const TextStyle(
              fontSize: HealingTheme.fsHeading,
              fontWeight: HealingTheme.wSemi,
              color: HealingColors.textPrimary,
            ),
          ),
          const SizedBox(height: HealingTheme.spacingXS),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: HealingTheme.fsBodySmall,
              color: HealingColors.textTertiary,
            ),
          ),
          const SizedBox(height: HealingTheme.spacingXS),
          Text(
            hint,
            style: const TextStyle(
              fontSize: HealingTheme.fsCaption,
              color: HealingColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context, InspirationProvider provider) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => _SearchScreen(provider: provider),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: a, child: child),
        ),
      ),
    );
  }

  void _showDetail(Inspiration inspiration) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => InspirationDetailScreen(inspiration: inspiration),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, a, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: a, child: child),
          );
        },
      ),
    );
  }

  void _showActions(InspirationProvider provider, Inspiration inspiration) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HealingTheme.radiusXL)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: HealingTheme.spacingSM),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HealingColors.textDisabled.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: HealingTheme.spacingMD),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: HealingColors.accentMint),
              title: const Text('编辑灵感'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, a, __) => EditorScreen(inspiration: inspiration),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (_, a, __, child) {
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
                            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                        child: FadeTransition(opacity: a, child: child),
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(provider, inspiration.id);
              },
            ),
            const SizedBox(height: HealingTheme.spacingSM),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(InspirationProvider provider, String id) {
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
              provider.delete(id);
              Navigator.pop(context);
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

  // ─── 日期过滤 ──────────────────────────────────────

  void _showDateFilter(BuildContext context, InspirationProvider provider) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HealingTheme.radiusXL)),
        child: _DateFilterSheet(provider: provider),
      ),
    );
  }

}

// ─── 日期过滤面板 ────────────────────────────────────

class _DateFilterSheet extends StatefulWidget {
  final InspirationProvider provider;
  const _DateFilterSheet({required this.provider});

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  late DateFilterMode _mode;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _mode = widget.provider.dateFilterMode;
    _startDate = widget.provider.customDateStart;
    _endDate = widget.provider.customDateEnd;
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime d) {
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }

  void _apply() {
    if (_mode == DateFilterMode.custom) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择开始日期'), duration: Duration(seconds: 2)),
        );
        return;
      }
      widget.provider.filterByDate(_mode, start: _startDate, end: _endDate);
    } else {
      widget.provider.filterByDate(_mode);
    }
    Navigator.pop(context);
  }

  void _reset() {
    widget.provider.clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.provider.dateFilterMode != DateFilterMode.all;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: HealingColors.textPrimary),
                const SizedBox(width: 8),
                const Text(
                  '按日期检索',
                  style: TextStyle(
                    fontSize: HealingTheme.fsBodyLarge,
                    fontWeight: HealingTheme.wSemi,
                  ),
                ),
                const Spacer(),
                if (isActive)
                  GestureDetector(
                    onTap: _reset,
                    child: const Text(
                      '清除筛选',
                      style: TextStyle(
                        fontSize: HealingTheme.fsCaption,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 快捷选项
            const Text(
              '快捷选择',
              style: TextStyle(
                fontSize: HealingTheme.fsBodySmall,
                fontWeight: HealingTheme.wMedium,
                color: HealingColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickChip('今天', DateFilterMode.today),
                _buildQuickChip('本周', DateFilterMode.week),
                _buildQuickChip('本月', DateFilterMode.month),
                _buildQuickChip('全部', DateFilterMode.all),
              ],
            ),
            const SizedBox(height: 18),

            // 自定义日期范围
            const Text(
              '自定义范围',
              style: TextStyle(
                fontSize: HealingTheme.fsBodySmall,
                fontWeight: HealingTheme.wMedium,
                color: HealingColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Center(child: _buildCustomDateChip()),
            const SizedBox(height: 20),

            // 统计信息
            if (isActive) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HealingColors.accentMint.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    const Icon(Icons.info_outline, size: 14, color: HealingColors.accentMint),
                    const SizedBox(width: 8),
                    Text(
                      _getFilterLabel(widget.provider.dateFilterMode),
                      style: const TextStyle(
                        fontSize: HealingTheme.fsCaption,
                        color: HealingColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '·',
                      style: TextStyle(color: HealingColors.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '共 ${widget.provider.inspirations.length} 条',
                      style: TextStyle(
                        fontSize: HealingTheme.fsCaption,
                        color: HealingColors.accentMint,
                        fontWeight: HealingTheme.wSemi,
                      ),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
    );
  }

  Widget _buildQuickChip(String label, DateFilterMode mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _mode = mode);
        _apply();
      },
      child: AnimatedContainer(
        duration: HealingTheme.animationNormal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? HealingColors.accentMint : Colors.transparent,
          borderRadius: BorderRadius.circular(HealingTheme.radiusFull),
          border: Border.all(
            color: isSelected ? HealingColors.accentMint : HealingColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: HealingTheme.fsCaption,
            fontWeight: HealingTheme.wMedium,
            color: isSelected ? Colors.white : HealingColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateChip() {
    final isSelected = _mode == DateFilterMode.custom;
    return GestureDetector(
      onTap: () => setState(() => _mode = DateFilterMode.custom),
      child: AnimatedContainer(
        duration: HealingTheme.animationNormal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? HealingColors.accentMint.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
          border: Border.all(
            color: isSelected ? HealingColors.accentMint : HealingColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 开始日期
            Expanded(
              child: GestureDetector(
                onTap: () => _pickDate(true),
                child: Row(
                  children: [
                    const Icon(Icons.event_note, size: 16, color: HealingColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      _startDate != null ? _formatDate(_startDate!) : '开始日期',
                      style: TextStyle(
                        fontSize: HealingTheme.fsBodySmall,
                        color: _startDate != null ? HealingColors.textPrimary : HealingColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 连接符
            const Icon(Icons.arrow_forward, size: 14, color: HealingColors.textTertiary),
            const SizedBox(width: 4),
            // 结束日期
            Expanded(
              child: GestureDetector(
                onTap: () => _pickDate(false),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _endDate != null ? _formatDate(_endDate!) : '结束日期',
                      style: TextStyle(
                        fontSize: HealingTheme.fsBodySmall,
                        color: _endDate != null ? HealingColors.textPrimary : HealingColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.event_note, size: 16, color: HealingColors.textTertiary),
                  ],
                ),
              ),
            ),
            // 确认按钮
            if (_mode == DateFilterMode.custom) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _apply,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HealingColors.accentMint,
                    borderRadius: BorderRadius.circular(HealingTheme.radiusSM),
                  ),
                  child: const Text(
                    '确定',
                    style: TextStyle(
                      fontSize: HealingTheme.fsCaption,
                      color: Colors.white,
                      fontWeight: HealingTheme.wSemi,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(DateFilterMode mode) {
    switch (mode) {
      case DateFilterMode.today:
        return '今天';
      case DateFilterMode.week:
        return '本周';
      case DateFilterMode.month:
        return '本月';
      case DateFilterMode.custom:
        return '${_startDate != null ? _formatDate(_startDate!) : '...'} 至 ${_endDate != null ? _formatDate(_endDate!) : '...'}';
      case DateFilterMode.all:
        return '全部';
    }
  }
}

class _SearchScreen extends StatefulWidget {
  final InspirationProvider provider;
  const _SearchScreen({required this.provider});

  @override
  State<_SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<_SearchScreen> {
  String _query = '';
  final _controller = TextEditingController();

  void _onSearch(String q) {
    setState(() => _query = q);
  }

  void _onTapResult(Inspiration inspiration) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => InspirationDetailScreen(inspiration: inspiration),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, a, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: a, child: child),
          );
        },
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case '灵感火花': return const Color(0xFFFFB87F);
      case '今日印记': return const Color(0xFF7FC8A8);
      case '真实情绪': return const Color(0xFF9F8FD5);
      default: return HealingColors.accentLavender;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? <Inspiration>[]
        : widget.provider.searchResults(_query);

    return Scaffold(
      backgroundColor: HealingColors.backgroundWarm,
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 14, color: HealingColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: HealingColors.cardBackground.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(HealingTheme.radiusFull),
                        border: Border.all(color: HealingColors.border.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: _onSearch,
                        decoration: const InputDecoration(
                          hintText: '搜索灵感...',
                          hintStyle: TextStyle(
                            color: HealingColors.textHint,
                            fontSize: HealingTheme.fsBody,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          prefixIcon: Icon(Icons.search, size: 18, color: HealingColors.textTertiary),
                          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: HealingColors.border),
            // 结果
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: HealingColors.textDisabled.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _query.isEmpty ? '输入关键词搜索灵感 ~' : '没有找到匹配的灵感 🤔',
                            style: const TextStyle(
                              fontSize: HealingTheme.fsBodySmall,
                              color: HealingColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: results.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => _onTapResult(results[i]),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: HealingColors.cardBackground.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(HealingTheme.radiusLG),
                              border: Border.all(
                                color: HealingColors.border.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  results[i].content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: HealingTheme.fsBody,
                                    color: HealingColors.textPrimary,
                                    height: 1.6,
                                  ),
                                ),
                                if (results[i].tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: results[i].tags.map((tag) {
                                      final tagColor = _getTagColor(tag);
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: tagColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(HealingTheme.radiusSM),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: tagColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(results[i].createdAt),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: HealingColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
