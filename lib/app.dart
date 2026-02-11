import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/create_sale_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_verification_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/filters_screen.dart';
import 'screens/search_alerts_screen.dart';
import 'data/categories.dart';

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
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        shadowColor: AppColors.glow,
        iconTheme: const IconThemeData(
          color: AppColors.primary,
        ),
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.neumorphicBase,
          indicatorColor: Colors.transparent,
          elevation: 0,
          height: 78,
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected) ? AppColors.primaryEnd : AppColors.textMuted,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w600,
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
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _SmoothPageTransitionsBuilder(),
            TargetPlatform.iOS: _SmoothPageTransitionsBuilder(),
            TargetPlatform.macOS: _SmoothPageTransitionsBuilder(),
            TargetPlatform.windows: _SmoothPageTransitionsBuilder(),
            TargetPlatform.linux: _SmoothPageTransitionsBuilder(),
            TargetPlatform.fuchsia: _SmoothPageTransitionsBuilder(),
          },
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.65),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintStyle: const TextStyle(color: AppColors.textMuted),
          labelStyle: const TextStyle(color: AppColors.textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.55), width: 1.2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.neumorphicBase,
            foregroundColor: AppColors.primaryEnd,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.buttonRadius)),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.78)),
            shadowColor: AppColors.neumorphicDarkShadow,
            surfaceTintColor: Colors.transparent,
            disabledBackgroundColor: AppColors.neumorphicBase.withValues(alpha: 0.65),
            disabledForegroundColor: AppColors.textMuted,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryEnd,
            backgroundColor: AppColors.neumorphicBase,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.buttonRadius)),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.78)),
            shadowColor: AppColors.neumorphicDarkShadow,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.buttonRadius)),
            foregroundColor: AppColors.primaryEnd,
            backgroundColor: AppColors.neumorphicBase,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.78)),
            surfaceTintColor: Colors.transparent,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neumorphicBase,
            foregroundColor: AppColors.primaryEnd,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.buttonRadius)),
            shadowColor: AppColors.neumorphicDarkShadow,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.buttonRadius)),
        ),
      ),
      builder: (context, child) {
        return _AppBackground(
          child: child ?? const SizedBox.shrink(),
        );
      },
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
        '/search-alerts': (_) => const SearchAlertsScreen(),
        '/jobs': (_) => const JobsScreen(),
        '/home': (_) => const AppShell(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/category') {
          final category = settings.arguments;
          if (category is CategoryItem) {
            return MaterialPageRoute<void>(
              builder: (_) => CategoryDetailScreen(category: category),
              settings: settings,
            );
          }
        }
        return null;
      },
    );
  }
}

class _AppBackground extends StatelessWidget {
  final Widget child;

  const _AppBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neumorphicBase,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -42,
            child: _BlurOrb(
              size: 220,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -48,
            child: _BlurOrb(
              size: 250,
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 52,
            spreadRadius: 10,
          ),
        ],
      ),
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

class _SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final slide = Tween<Offset>(
      begin: const Offset(0.045, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
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
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.neumorphicBase,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.neumorphicLightShadow,
              blurRadius: 12,
              offset: const Offset(-5, -5),
            ),
            BoxShadow(
              color: AppColors.neumorphicDarkShadow,
              blurRadius: 14,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) {
            if (value == _publishTabIndex) {
              _showPublishSheet(context);
            }
            setState(() => _index = value);
          },
          destinations: [
            NavigationDestination(
              icon: _navIcon(Icons.home_outlined, false),
              selectedIcon: _navIcon(Icons.home_rounded, true),
              label: 'Home',
            ),
            NavigationDestination(
              icon: _navIcon(Icons.favorite_border, false),
              selectedIcon: _navIcon(Icons.favorite, true),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: _navIcon(Icons.add_circle_outline, false),
              selectedIcon: _navIcon(Icons.add_circle, true),
              label: 'Publicar',
            ),
            NavigationDestination(
              icon: _navIcon(Icons.chat_bubble_outline, false),
              selectedIcon: _navIcon(Icons.chat_bubble, true),
              label: 'Mensagens',
            ),
            NavigationDestination(
              icon: _navIcon(Icons.person_outline, false),
              selectedIcon: _navIcon(Icons.person, true),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, bool selected) {
    return Container(
      width: 42,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.neumorphicBase,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neumorphicLightShadow,
            blurRadius: 6,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: AppColors.neumorphicDarkShadow,
            blurRadius: 7,
            offset: const Offset(3, 3),
          ),
          if (selected)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              spreadRadius: 0.2,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Icon(
        icon,
        size: 21,
        color: selected ? AppColors.primaryEnd : AppColors.textMuted,
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
