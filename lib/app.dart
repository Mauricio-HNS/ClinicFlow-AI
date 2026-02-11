import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/create_sale_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
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
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.highlight,
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              size: 26,
              color: states.contains(WidgetState.selected) ? AppColors.primaryEnd : AppColors.textMuted,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected) ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
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

  static const int _publishTabIndex = 2;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    CreateSaleScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          if (value == _publishTabIndex) {
            _showPublishSheet(context);
          }
          setState(() => _index = value);
        },
        height: 72,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Publicar'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Mensagens'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  void _showPublishSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.sell_outlined),
                  title: const Text('Vender item'),
                  subtitle: const Text('Publique um anúncio no marketplace'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _index = _publishTabIndex);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business_center_outlined),
                  title: const Text('Publicar vaga'),
                  subtitle: const Text('Crie uma vaga e receba candidatos'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.person_search_outlined),
                  title: const Text('Procurar emprego'),
                  subtitle: const Text('Ative seu perfil para empresas'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
