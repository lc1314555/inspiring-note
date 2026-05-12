import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/inspiration_provider.dart';
import '../../widgets/healing_background.dart';
import '../../services/hive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _currentNoise;
  bool _isPlaying = false;

  void _refreshPlayerState() {
    setState(() {
      _currentNoise = WhiteNoisePlayer.currentNoise;
      _isPlaying = WhiteNoisePlayer.isPlaying;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentNoise = WhiteNoisePlayer.currentNoise;
    _isPlaying = WhiteNoisePlayer.isPlaying;
  }

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<ThemeProvider>(context);
    final currentTheme = tp.theme;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // 主题外观
          _buildSectionHeader('主题外观'),
          _buildThemeGrid(currentTheme, tp),
          const SizedBox(height: HealingTheme.spacingMD),
          const Divider(height: 1),

          // 动态背景
          _buildSectionHeader('动态背景'),
          _buildToggle(
            Icons.animation,
            '启用粒子动画',
            tp.particleEnabled,
            (v) => tp.setParticleEnabled(v),
          ),
          _buildSliderRow(
            Icons.bubble_chart,
            '粒子数量',
            tp.particleCount.toDouble(),
            min: 5,
            max: 30,
            divisions: 25,
            onChanged: (v) => tp.setParticleCount(v.toInt()),
          ),
          // 自动切换开关
          _buildToggle(
            Icons.autorenew,
            '自动切换主题',
            tp.autoSwitch,
            (v) => tp.setAutoSwitch(v),
          ),
          // 切换间隔（仅自动切换开启时可见）
          if (tp.autoSwitch)
            _buildSliderRow(
              Icons.timer,
              '切换间隔 (分钟)',
              tp.themeInterval,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => tp.setThemeInterval(v),
            ),
          const SizedBox(height: HealingTheme.spacingSM),
          const Divider(height: 1),

          // 背景音乐
          _buildSectionHeader('背景音乐'),
          _buildSoundSelector(),
          const SizedBox(height: HealingTheme.spacingSM),
          const Divider(height: 1),

          // 数据管理
          _buildSectionHeader('数据管理'),
          _buildListTile(Icons.backup_outlined, '导出数据', onTap: _exportData),
          _buildListTile(Icons.restore_outlined, '导入数据', onTap: _importData),
          _buildListTile(
            Icons.delete_sweep_outlined,
            '清空所有数据',
            textColor: Colors.red,
            onTap: _confirmClearAll,
          ),
          const SizedBox(height: HealingTheme.spacingSM),
          const Divider(height: 1),

          // 关于
          _buildSectionHeader('关于'),
          _buildListTile(Icons.info_outline, '版本', trailing: const Text('1.0.0')),
          _buildListTile(Icons.favorite_outline, '心流屋',
              trailing: const Text('一个安放思绪的房间')),
          const SizedBox(height: HealingTheme.spacingXXL),

          // 底部
          Center(
            child: Text(
              'Made with 💚',
              style: TextStyle(
                fontSize: HealingTheme.fsCaption,
                color: HealingColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: HealingTheme.spacingLG),
        ],
      ),
    );
  }

  Widget _buildThemeGrid(ThemeConfig currentTheme, ThemeProvider tp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: HealingThemes.all.asMap().entries.map((entry) {
          final index = entry.key;
          final theme = entry.value;
          final isSelected = theme.name == currentTheme.name;
          return GestureDetector(
            onTap: () => tp.setTheme(index),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: theme.background,
                ),
                borderRadius: BorderRadius.circular(HealingTheme.radiusLG),
                border: Border.all(
                  color: isSelected ? theme.accent : Colors.transparent,
                  width: isSelected ? 2.5 : 0,
                ),
                boxShadow: isSelected ? [HealingTheme.boxShadowGlow] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: theme.particleColors.map((c) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    theme.name,
                    style: TextStyle(
                      fontSize: HealingTheme.fsCaption,
                      fontWeight: HealingTheme.wMedium,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Icon(Icons.check_circle, size: 14, color: theme.accent),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── 背景音乐 ──────────────────────────────────────

  Widget _buildSoundSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD, vertical: 8),
      child: Row(
        children: [
          _buildSoundOption('rain', '🌧️ 雨声'),
          const SizedBox(width: 12),
          _buildSoundOption('stream', '🌊 溪流'),
        ],
      ),
    );
  }

  Widget _buildSoundOption(String noiseKey, String label) {
    final isSelected = WhiteNoisePlayer.preferredSound == noiseKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          WhiteNoisePlayer.setPreferredSound(noiseKey);
          _refreshPlayerState();
        },
        child: AnimatedContainer(
          duration: HealingTheme.animationNormal,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? HealingColors.accentMint.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
            border: Border.all(
              color: isSelected ? HealingColors.accentMint : HealingColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? [HealingTheme.boxShadowSubtle] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label.split(' ')[0], style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                label.split(' ')[1],
                style: TextStyle(
                  fontSize: HealingTheme.fsBody,
                  fontWeight: isSelected ? HealingTheme.wSemi : FontWeight.normal,
                  color: isSelected ? HealingColors.accentMint : HealingColors.textPrimary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, size: 14, color: HealingColors.accentMint),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(HealingTheme.spacingMD, HealingTheme.spacingMD, HealingTheme.spacingMD, HealingTheme.spacingSM),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: HealingTheme.fsCaption,
          fontWeight: HealingTheme.wSemi,
          color: HealingColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildToggle(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: HealingColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: HealingTheme.fsBody)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: HealingColors.accentMint,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    IconData icon,
    String label,
    double value, {
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: HealingColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: HealingTheme.fsBody)),
              ),
              Text(
                label == '音量' ? (value * 100).toInt().toString() + '%' : (max % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1)),
                style: const TextStyle(
                  fontSize: HealingTheme.fsCaption,
                  color: HealingColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
              activeTrackColor: HealingColors.accentMint,
              inactiveTrackColor: HealingColors.accentMint.withOpacity(0.2),
              thumbColor: HealingColors.accentMint,
              overlayColor: HealingColors.accentMint.withOpacity(0.15),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title, {
    Color? textColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: textColor ?? HealingColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: HealingTheme.fsBody,
          color: textColor ?? HealingColors.textPrimary,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: HealingColors.textDisabled),
      onTap: onTap,
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能开发中 ~'), duration: Duration(seconds: 2)),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入功能开发中 ~'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HealingTheme.radiusXL)),
        title: const Text('确认清空？'),
        content: const Text('所有灵感数据将被永久删除，此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<InspirationProvider>(context, listen: false);
      // 清空所有数据
      for (final item in provider.inspirations) {
        await HiveService.delete(item.id);
      }
      await provider.load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已清空'), duration: Duration(seconds: 2)),
        );
      }
    }
  }
}
