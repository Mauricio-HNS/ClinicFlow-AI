import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'theme/app_colors.dart';
import 'screens/map_screen.dart';
import 'screens/list_screen.dart';
import 'screens/create_sale_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_verification_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/filters_screen.dart';

class GarageSaleApp extends StatelessWidget {
  const GarageSaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GarageSale Madrid',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.canvas,
        shadowColor: AppColors.glow,
        useMaterial3: true,
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 15, height: 1.4, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: AppColors.textMuted),
          bodySmall: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMuted),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            side: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.12)),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/auth': (_) => const AuthScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/profile-verification': (_) => const ProfileVerificationScreen(),
        '/categories': (_) => const CategoriesScreen(),
        '/filters': (_) => const FiltersScreen(),
        '/home': (_) => const AppShell(),
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    MapScreen(),
    JobsScreen(),
    ListScreen(),
    CreateSaleScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        height: 72,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline), label: 'Empregos'),
          NavigationDestination(
            icon: Icon(Icons.view_list_outlined),
            label: 'Lista',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Criar',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
