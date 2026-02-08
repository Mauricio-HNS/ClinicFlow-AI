import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/map_screen.dart';
import 'screens/list_screen.dart';
import 'screens/create_sale_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

class GarageSaleApp extends StatelessWidget {
  const GarageSaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GarageSale Madrid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.canvas,
        useMaterial3: true,
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 15, height: 1.4),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4),
          bodySmall: TextStyle(fontSize: 12, height: 1.4),
        ),
      ),
      initialRoute: '/splash',
      routes: {\n        '/splash': (_) => const SplashScreen(),\n        '/onboarding': (_) => const OnboardingScreen(),\n        '/auth': (_) => const AuthScreen(),\n        '/login': (_) => const LoginScreen(),\n        '/register': (_) => const RegisterScreen(),\n        '/home': (_) => const AppShell(),\n      },
    );
  }
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
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.view_list_outlined), label: 'Lista'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Criar'),
          NavigationDestination(icon: Icon(Icons.notifications_none), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
