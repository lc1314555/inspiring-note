import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onEnter;
  const WelcomeScreen({super.key, required this.onEnter});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeTitle;
  late Animation<double> _fadeSubtitle;
  late Animation<double> _fadeButton;
  late Animation<Offset> _slideTitle;
  late Animation<Offset> _slideSubtitle;
  late Animation<Offset> _slideButton;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeTitle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );
    _slideTitle = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );

    _fadeSubtitle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );
    _slideSubtitle = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );

    _fadeButton = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOut)),
    );
    _slideButton = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F5F2),
              Color(0xFFF0EDE8),
              Color(0xFFE8E0D8),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 装饰粒子
            ..._buildDecorations(),
            // 主内容
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo 区域
                    SlideTransition(
                      position: _slideTitle,
                      child: FadeTransition(
                        opacity: _fadeTitle,
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: HealingColors.accentMint.withOpacity(0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: HealingColors.accentMint.withOpacity(0.1),
                                    blurRadius: 60,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lightbulb,
                                size: 56,
                                color: HealingColors.accentMint,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              '心流屋',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: HealingColors.textPrimary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 介绍文字
                    SlideTransition(
                      position: _slideSubtitle,
                      child: FadeTransition(
                        opacity: _fadeSubtitle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: HealingColors.accentMint.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '温暖治愈的心绪记录空间',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HealingColors.accentMint,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '记录灵感火花 · 收藏生活印记 · 安放真实情绪',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: HealingColors.textSecondary,
                                  height: 1.8,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 进入按钮
                    SlideTransition(
                      position: _slideButton,
                      child: FadeTransition(
                        opacity: _fadeButton,
                        child: GestureDetector(
                          onTap: widget.onEnter,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  HealingColors.accentMint,
                                  Color(0xFF8CC5A8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: HealingColors.accentMint.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '进入心流',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 20, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 底部版权
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeButton,
                child: const Text(
                  '每一个进入心流的瞬间，都值得被留下来 ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: HealingColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorations() {
    return [
      _buildParticle(0.12, 0.15, 30, 0.06),
      _buildParticle(0.82, 0.08, 20, 0.04),
      _buildParticle(0.75, 0.72, 45, 0.05),
      _buildParticle(0.15, 0.65, 25, 0.04),
      _buildParticle(0.45, 0.25, 35, 0.05),
      _buildParticle(0.90, 0.45, 18, 0.03),
      _buildParticle(0.05, 0.38, 22, 0.04),
      _buildParticle(0.60, 0.90, 28, 0.05),
    ];
  }

  Widget _buildParticle(double x, double y, double size, double opacity) {
    return Positioned(
      left: x * MediaQuery.of(context).size.width,
      top: y * MediaQuery.of(context).size.height,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HealingColors.accentMint.withOpacity(opacity),
        ),
      ),
    );
  }
}
