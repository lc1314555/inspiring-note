import 'package:flutter/material.dart';
import '../models/inspiration.dart';
import '../utils/constants.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String?> onChanged;

  const MoodSelector({super.key, this.selectedMood, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: HealingTheme.spacingMD, vertical: 12),
      decoration: BoxDecoration(
        color: HealingColors.cardBackground.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: HealingColors.border.withOpacity(0.4), width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: moodOptions.map((option) => _buildMoodButton(option)).toList(),
        ),
      ),
    );
  }

  Widget _buildMoodButton(MoodOption option) {
    final isSelected = selectedMood == option.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => onChanged(isSelected ? null : option.value),
        child: AnimatedContainer(
          duration: HealingTheme.animationNormal,
          curve: Curves.easeOutBack,
          width: 52,
          height: 62,
          decoration: BoxDecoration(
            color: isSelected ? HealingColors.accentMint.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(HealingTheme.radiusLG),
            border: Border.all(
              color: isSelected ? HealingColors.accentMint : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(option.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: HealingTheme.fsCaption,
                  color: isSelected ? HealingColors.textPrimary : HealingColors.textTertiary,
                  fontWeight: isSelected ? HealingTheme.wMedium : HealingTheme.wRegular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
