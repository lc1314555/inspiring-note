import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:js' as js;
import '../utils/constants.dart';
import '../providers/theme_provider.dart';

/// 🎨 治愈风动态背景：跟随 ThemeProvider + 浮动粒子
class HealingBackground extends StatefulWidget {
  final Widget child;

  const HealingBackground({super.key, required this.child});

  @override
  State<HealingBackground> createState() => _HealingBackgroundState();
}

class _HealingBackgroundState extends State<HealingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final _random = Random();

  // 平滑过渡
  ThemeConfig? _currentTheme;
  ThemeConfig _targetTheme = HealingThemes.warm;
  double _transitionProgress = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    _targetTheme = tp.theme;
    if (_currentTheme == null) {
      _currentTheme = tp.theme;
      _transitionProgress = 1.0;
    }
    _initParticles();
    _autoCycle();
  }

  void _autoCycle() {
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    if (tp.autoSwitch) {
      Future.delayed(
        Duration(minutes: tp.themeInterval.toInt()),
        () {
          if (mounted) {
            tp.switchToNext();
            _startTransition();
            _autoCycle();
          }
        },
      );
    }
  }

  void _startTransition() {
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    _currentTheme = tp.theme;
    _transitionProgress = 0.0;
    _animateTransition();
  }

  Future<void> _animateTransition() async {
    const steps = 40;
    const duration = Duration(seconds: 3);
    for (int i = 0; i <= steps; i++) {
      if (!mounted) return;
      await Future.delayed(duration ~/ steps);
      setState(() => _transitionProgress = i / steps);
    }
    setState(() => _transitionProgress = 1.0);
  }

  void _initParticles() {
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    _particles.clear();
    for (int i = 0; i < tp.particleCount; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 15 + _random.nextDouble() * 50,
        speed: 0.001 + _random.nextDouble() * 0.004,
        colorIndex: _random.nextInt(3),
        phase: _random.nextDouble() * 2 * pi,
      ));
    }
  }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (ctx, tp, _) {
        // 响应主题变化
        if (_targetTheme.name != tp.theme.name) {
          _targetTheme = tp.theme;
          _startTransition();
        }

        // 粒子数量变化时重新初始化
        if (_particles.length != tp.particleCount) {
          _initParticles();
        }

        final current = _currentTheme ?? tp.theme;
        final t = _transitionProgress;
        final size = MediaQuery.of(context).size;

        final bgColors = [
          _lerpColor(current.background[0], _targetTheme.background[0], t),
          _lerpColor(current.background[1], _targetTheme.background[1], t),
          _lerpColor(current.background[2], _targetTheme.background[2], t),
        ];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgColors,
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              if (tp.particleEnabled)
                ..._particles.map((p) => Positioned(
                      left: (p.x + sin(_controller.value * 2 * pi * p.speed + p.phase) * 0.08) * size.width,
                      top: (p.y + cos(_controller.value * 2 * pi * p.speed * 0.7 + p.phase) * 0.08) * size.height,
                      child: Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _lerpColor(
                            current.particleColors[p.colorIndex],
                            _targetTheme.particleColors[p.colorIndex],
                            t,
                          ).withOpacity(0.04 + p.size / 200),
                        ),
                      ),
                    )),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x, y, size, speed, phase;
  final int colorIndex;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.colorIndex,
    required this.phase,
  });
}

/// 🎵 白噪声播放器 — Web 用 HTML5 Audio 直接播放
class WhiteNoisePlayer {
  static bool _isPlaying = false;
  static String? _currentNoise;
  static String _preferredSound = 'rain'; // 设置页选择的音效

  static const Map<String, String> _audioFiles = {
    'rain': 'assets/assets/audio/rain.mp3',
    'stream': 'assets/assets/audio/stream.mp3',
  };

  static void play(String? noiseValue) {
    final sound = noiseValue ?? _preferredSound;
    final assetPath = _audioFiles[sound];
    if (assetPath == null) return;

    // 如果已经在播放同一种声音，切换为停止
    if (_currentNoise == sound && _isPlaying) {
      stop();
      return;
    }

    final jsCode = '''
      (function() {
        if (window._noisePlayer) { window._noisePlayer.pause(); }
        window._noisePlayer = new Audio("$assetPath");
        window._noisePlayer.loop = true;
        window._noisePlayer.play().catch(function(e) { console.log("Audio play blocked:", e); });
      })()
    ''';
    js.context.callMethod('eval', [jsCode]);

    _isPlaying = true;
    _currentNoise = sound;
    debugPrint('🎵 播放白噪声: $sound (path: $assetPath)');
  }

  static void stop() {
    js.context.callMethod('eval', [
      'if(window._noisePlayer){window._noisePlayer.pause();window._noisePlayer=null;}'
    ]);
    _isPlaying = false;
    _currentNoise = null;
    debugPrint('🔇 停止白噪声');
  }

  static void setPreferredSound(String sound) {
    _preferredSound = sound;
    debugPrint('🎵 偏好音效: $sound');
  }

  static bool get isPlaying => _isPlaying;
  static String? get currentNoise => _currentNoise;
  static String get preferredSound => _preferredSound;
}
