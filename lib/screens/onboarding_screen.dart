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
    ),
    _OnboardPage(
      title: 'Crie sua venda em minutos',
      subtitle: 'Cadastro rápido, fotos e localização aproximada.',
      icon: Icons.add_circle_outline,
    ),
    _OnboardPage(
      title: 'Destaque e venda mais',
      subtitle: 'Apareça no topo do mapa e receba mais visitas.',
      icon: Icons.star_outline,
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
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
                    child: const Text('Pular'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (_page < _pages.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      } else {
                        Navigator.pushReplacementNamed(context, '/auth');
                      }
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text(_page == _pages.length - 1 ? 'Começar' : 'Próximo'),
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

  const _OnboardPage({required this.title, required this.subtitle, required this.icon});

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
            child: Icon(icon, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 32),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 12),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
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
