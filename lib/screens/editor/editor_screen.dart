import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/inspiration.dart';
import '../../providers/inspiration_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/healing_background.dart';
import '../../utils/platform_image.dart';

// 写作引导文案 — 按分类
const Map<String, List<String>> categoryPrompts = {
  '灵感火花': [
    '脑海中闪过了什么有趣的想法？',
    '如果一切皆有可能，你会做什么？',
    '有什么可以打破常规？',
    '这个点子可以怎样延伸？',
    '一个不寻常的组合会诞生什么？',
  ],
  '今日印记': [
    '今天发生了什么值得记住的事？',
    '哪个瞬间让你嘴角上扬？',
    '今天遇见了谁、做了什么？',
    '生活中有什么小确幸？',
    '如果给今天拍一张快照，会是什么画面？',
  ],
  '真实情绪': [
    '此刻的你，心里装着什么？',
    '用一个颜色来形容现在的心情？',
    '有什么想对自己说的温柔话？',
    '深呼吸，感受当下的情绪...',
    '不需要理由，只是此刻的感受。',
  ],
};

const List<String> defaultPrompts = [
  '此刻的你，心里装着什么？',
  '今天有什么想记录的？',
  '写给自己的三行字...',
  '捕捉那一闪而过的念头',
  '慢慢写，不着急',
];

class EditorScreen extends StatefulWidget {
  final Inspiration? inspiration;
  final String? category;
  const EditorScreen({super.key, this.inspiration, this.category});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  String? _selectedMood;
  String? _selectedImagePath;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _floatController;

  bool get _showMood => widget.category == '真实情绪';
  int get _promptIndex => DateTime.now().minute % (_prompts.length);
  List<String> get _prompts => categoryPrompts[widget.category] ?? defaultPrompts;
  String get _placeholder => _prompts[_promptIndex];

  String get _categoryIcon {
    switch (widget.category) {
      case '灵感火花': return '💡';
      case '今日印记': return '📸';
      case '真实情绪': return '🌊';
      default: return '✨';
    }
  }

  String get _categorySubtitle {
    switch (widget.category) {
      case '灵感火花': return '闪光的想法与创意';
      case '今日印记': return '生活中的小片段';
      case '真实情绪': return '内心真实感受';
      default: return '';
    }
  }

  Color get _categoryAccent {
    switch (widget.category) {
      case '灵感火花': return const Color(0xFFFF9E5E);
      case '今日印记': return const Color(0xFF5EC4A0);
      case '真实情绪': return const Color(0xFF9F8FD5);
      default: return HealingColors.accentMint;
    }
  }

  Color get _categoryAccentLight {
    switch (widget.category) {
      case '灵感火花': return const Color(0xFFFFF5EB);
      case '今日印记': return const Color(0xFFEBF8F3);
      case '真实情绪': return const Color(0xFFF2EFF9);
      default: return const Color(0xFFF0F8F4);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.inspiration != null) {
      _controller.text = widget.inspiration!.content;
      _selectedMood = widget.inspiration!.mood;
      _selectedImagePath = widget.inspiration!.imagePath;
    }
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.inspiration != null;
    final hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HealingBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isEdit, hasText),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.category != null) ...[
                        _buildCategoryHeader(),
                        const SizedBox(height: 20),
                      ],
                      if (_showMood) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: MoodSelector(
                            selectedMood: _selectedMood,
                            onChanged: (v) => setState(() => _selectedMood = v),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildWritingArea(),
                      if (_selectedImagePath != null) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildImagePreview(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 顶部导航 ──────────────────────────────────────

  Widget _buildHeader(bool isEdit, bool hasText) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? '编辑${_getCategoryName()}' : _getCategoryAction(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: HealingColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _formatNow(),
                style: const TextStyle(
                  fontSize: 11,
                  color: HealingColors.textTertiary,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: hasText && !_isSaving ? _save : null,
            child: AnimatedContainer(
              duration: HealingTheme.animationNormal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: hasText ? _categoryAccent : HealingColors.textDisabled.withOpacity(0.15),
                borderRadius: BorderRadius.circular(HealingTheme.radiusFull),
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasText)
                          const Icon(Icons.check, size: 14, color: Colors.white),
                        if (hasText) const SizedBox(width: 4),
                        Text(
                          isEdit ? '更新' : _getCategorySave(),
                          style: TextStyle(
                            color: hasText ? Colors.white : HealingColors.textTertiary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 类别头部 ──────────────────────────────────────

  Widget _buildCategoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 图标
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _categoryAccentLight,
              shape: BoxShape.circle,
              border: Border.all(color: _categoryAccent.withOpacity(0.2), width: 1),
            ),
            child: Center(child: Text(_categoryIcon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: HealingColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _categorySubtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: HealingColors.textTertiary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 装饰线
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: _categoryAccent.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 写作区域 ──────────────────────────────────────

  Widget _buildWritingArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _categoryAccent.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 引导文案
          Row(
            children: [
              Opacity(
                opacity: 0.5,
                child: Text(_categoryIcon, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _placeholder,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HealingColors.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 分隔线
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _categoryAccent.withOpacity(0.25),
                  _categoryAccent.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // 输入
          TextField(
            controller: _controller,
            maxLines: null,
            maxLength: 2000,
            autofocus: widget.inspiration == null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: '写点什么...',
              hintStyle: TextStyle(
                color: HealingColors.textHint,
                fontSize: 16,
                height: 2.0,
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 2.0,
              color: HealingColors.textPrimary,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ─── 图片预览 ──────────────────────────────────────

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          PlatformImage(
            imagePath: _selectedImagePath,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // 底部渐变
          Positioned(
            bottom: 0, left: 0, right: 0, height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
          // 删除按钮
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImagePath = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: HealingColors.textSecondary, size: 13),
              ),
            ),
          ),
          // 图片标签
          Positioned(
            bottom: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📷 已添加图片',
                style: TextStyle(fontSize: 11, color: HealingColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 底部工具栏 ────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 字数统计
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${_controller.text.length}/2000',
                  style: const TextStyle(
                    fontSize: 11,
                    color: HealingColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 工具按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolButton(Icons.photo_outlined, '相册', _pickImage),
                _buildToolButton(Icons.camera_alt_outlined, '拍照', _takePhoto),
                _buildToolButton(Icons.mic_none_outlined, '语音', _recordVoice),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _categoryAccentLight,
                shape: BoxShape.circle,
                border: Border.all(color: _categoryAccent.withOpacity(0.15), width: 1),
              ),
              child: Icon(icon, size: 18, color: _categoryAccent),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: HealingColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 图片操作 ──────────────────────────────────────

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null && mounted) {
        setState(() => _selectedImagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('图片选择失败: $e')));
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (image != null && mounted) {
        setState(() => _selectedImagePath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('拍照失败: $e')));
      }
    }
  }

  void _recordVoice() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('语音功能开发中 🎤')));
  }

  // ─── 保存 ──────────────────────────────────────────

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() => _isSaving = true);

    final tags = <String>[];
    if (widget.category != null) tags.add(widget.category!);

    try {
      if (widget.inspiration != null) {
        await Provider.of<InspirationProvider>(context, listen: false).update(
          widget.inspiration!.copyWith(
            content: content, tags: tags, mood: _selectedMood, imagePath: _selectedImagePath,
          ),
        );
      } else {
        await Provider.of<InspirationProvider>(context, listen: false).add(
          Inspiration(content: content, tags: tags, mood: _selectedMood, imagePath: _selectedImagePath),
        );
      }

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
            });
            return Dialog(
              backgroundColor: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1.0),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _categoryAccent.withOpacity(0.3),
                            blurRadius: 28,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 48, color: _categoryAccent),
                          const SizedBox(height: 6),
                          Text(
                            _getCategoryDone(),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HealingColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.category != null ? '${widget.category} +1' : '心流屋 +1',
                            style: const TextStyle(fontSize: 11, color: HealingColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
        if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatNow() {
    final now = DateTime.now();
    final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return '${now.month}月${now.day}日 ${weekdays[now.weekday % 7]} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getCategoryName() {
    switch (widget.category) {
      case '灵感火花': return '灵感';
      case '今日印记': return '生活';
      case '真实情绪': return '情绪';
      default: return '灵感';
    }
  }

  String _getCategoryAction() {
    switch (widget.category) {
      case '灵感火花': return '记录灵感';
      case '今日印记': return '记录点滴';
      case '真实情绪': return '记录情绪';
      default: return '记录';
    }
  }

  String _getCategorySave() {
    switch (widget.category) {
      case '灵感火花': return '收藏灵感';
      case '今日印记': return '保存点滴';
      case '真实情绪': return '安放情绪';
      default: return '收藏';
    }
  }

  String _getCategoryDone() {
    switch (widget.category) {
      case '灵感火花': return '已收藏';
      case '今日印记': return '已保存';
      case '真实情绪': return '已安放';
      default: return '已收藏';
    }
  }
}
