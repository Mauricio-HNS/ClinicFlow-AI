import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      title: 'Vendas rápidas por perto',
      subtitle: 'Veja em segundos as vendas de garagem próximas em Madrid.',
      icon: Icons.map_outlined,
      imagePath: 'assets/onboarding/1.png',
    ),
    _OnboardPage(
      title: 'Crie sua venda em minutos',
      subtitle: 'Cadastro rápido, fotos e localização aproximada.',
      icon: Icons.add_circle_outline,
      imagePath: 'assets/onboarding/2.png',
    ),
    _OnboardPage(
      title: 'Destaque e venda mais',
      subtitle: 'Apareça no topo do mapa e receba mais visitas.',
      icon: Icons.star_outline,
      imagePath: 'assets/onboarding/3.png',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) => _pages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  _Dots(count: _pages.length, index: _page),
                  const Spacer(),
                  _NeumorphicPillButton(
                    label: 'Pular',
                    compact: true,
                    onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
                  ),
                  const SizedBox(width: 8),
                  _NeumorphicRoundButton(
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_page < _pages.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
                      } else {
                        Navigator.pushReplacementNamed(context, '/auth');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _NeumorphicPillButton(
                    label: _page == _pages.length - 1 ? 'Começar' : 'Próximo',
                    onPressed: () {
                      if (_page < _pages.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
                      } else {
                        Navigator.pushReplacementNamed(context, '/auth');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String imagePath;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.highlight,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 32),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 12),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Expanded(
            child: _OnboardImage(imagePath: imagePath, fallbackIcon: icon),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Tudo local, rápido e seguro.', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardImage extends StatelessWidget {
  final String imagePath;
  final IconData fallbackIcon;

  const _OnboardImage({required this.imagePath, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        return Center(
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(fallbackIcon, size: 64, color: AppColors.primary),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          width: i == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == index ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _NeumorphicRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NeumorphicRoundButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.neumorphicBase,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neumorphicLightShadow,
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
                BoxShadow(
                  color: AppColors.neumorphicDarkShadow,
                  blurRadius: 12,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primaryEnd, size: 28),
          ),
        ),
      ),
    );
  }
}

class _NeumorphicPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool compact;

  const _NeumorphicPillButton({
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 42 : 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 22),
            decoration: BoxDecoration(
              color: AppColors.neumorphicBase,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neumorphicLightShadow,
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
                BoxShadow(
                  color: AppColors.neumorphicDarkShadow,
                  blurRadius: 12,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryEnd,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
