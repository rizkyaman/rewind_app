import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/routes.dart';
import 'data/fake_repository.dart';
import 'screens/activities_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/login_screen.dart';
import 'screens/outcome_screen.dart';
import 'screens/result_screen.dart';
import 'screens/session_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/substitute_pick_screen.dart';
import 'screens/trigger_log_screen.dart';
import 'viewmodels/activity_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/rewind_viewmodel.dart';
import 'viewmodels/session_viewmodel.dart';

/// Root aplikasi. Semua ViewModel dibuat SEKALI di sini (di atas Navigator),
/// sehingga state tidak hilang saat layar diputar maupun saat pindah halaman.
class RewindApp extends StatelessWidget {
  const RewindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FakeRepository>(create: (_) => FakeRepository()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (c) => AuthViewModel(c.read<FakeRepository>()),
        ),
        ChangeNotifierProvider<SessionViewModel>(
          create: (c) => SessionViewModel(c.read<FakeRepository>()),
        ),
        ChangeNotifierProvider<ActivityViewModel>(
          create: (c) => ActivityViewModel(c.read<FakeRepository>()),
        ),
        ChangeNotifierProvider<RewindViewModel>(create: (_) => RewindViewModel()),
      ],
      child: MaterialApp(
        title: 'Rewind',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1C2220),
                        Color(0xFF121514),
                      ],
                    )
                  : AppColors.backgroundGradient,
            ),
            child: child,
          );
        },
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (_) => const SplashScreen(),
          Routes.login: (_) => const LoginScreen(),
          Routes.dashboard: (_) => const DashboardScreen(),
          Routes.breathing: (_) => const BreathingScreen(),
          Routes.trigger: (_) => const TriggerLogScreen(),
          Routes.substitute: (_) => const SubstitutePickScreen(),
          Routes.outcome: (_) => const OutcomeScreen(),
          Routes.result: (_) => const ResultScreen(),
          Routes.history: (_) => const HistoryScreen(),
          Routes.sessionDetail: (_) => const SessionDetailScreen(),
          Routes.insights: (_) => const InsightsScreen(),
          Routes.activities: (_) => const ActivitiesScreen(),
          Routes.settings: (_) => const SettingsScreen(),
        },
        // Rute tak dikenal: jangan crash, arahkan ke splash.
        onUnknownRoute: (_) =>
            MaterialPageRoute(builder: (_) => const SplashScreen()),
      ),
    );
  }
}
