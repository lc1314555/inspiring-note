import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'services/hive_service.dart';
import 'providers/inspiration_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'widgets/healing_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const InspirationApp());
}

final _navigatorKey = GlobalKey<NavigatorState>();

class InspirationApp extends StatelessWidget {
  const InspirationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InspirationProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, tp, _) {
          final theme = tp.theme;
          return MaterialApp(
            title: '心流屋',
            debugShowCheckedModeBanner: false,
            theme: _buildHealingTheme(theme),
            navigatorKey: _navigatorKey,
            home: WelcomeScreen(
              onEnter: () {
                _navigatorKey.currentState?.pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (_, a, __) => HealingBackground(child: HomeScreen()),
                    transitionDuration: const Duration(milliseconds: 600),
                    transitionsBuilder: (_, a, __, child) {
                      return FadeTransition(opacity: a, child: child);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildHealingTheme(ThemeConfig theme) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: theme.accent,
        surface: theme.card,
        primary: theme.accent,
        secondary: theme.accent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: theme.textPrimary,
          fontSize: HealingTheme.fsHeading,
          fontWeight: HealingTheme.wSemi,
        ),
      ),
      cardTheme: CardThemeData(
        color: theme.card,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealingTheme.radiusLG),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.card.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
          borderSide: BorderSide(color: theme.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HealingTheme.radiusMD),
          borderSide: BorderSide(color: theme.accent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HealingTheme.radiusXXL),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: theme.textPrimary,
          fontSize: HealingTheme.fsDisplay,
          fontWeight: HealingTheme.wBold,
          height: HealingTheme.lhTight,
        ),
        titleLarge: TextStyle(
          color: theme.textPrimary,
          fontSize: HealingTheme.fsHeading,
          fontWeight: HealingTheme.wSemi,
          height: HealingTheme.lhTight,
        ),
        bodyLarge: TextStyle(
          color: theme.textPrimary,
          fontSize: HealingTheme.fsBody,
          fontWeight: HealingTheme.wRegular,
          height: HealingTheme.lhNormal,
        ),
        bodyMedium: TextStyle(
          color: theme.textSecondary,
          fontSize: HealingTheme.fsBodySmall,
          fontWeight: HealingTheme.wRegular,
          height: HealingTheme.lhNormal,
        ),
        labelSmall: TextStyle(
          color: theme.textSecondary,
          fontSize: HealingTheme.fsCaption,
          fontWeight: HealingTheme.wMedium,
          letterSpacing: 0.5,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
