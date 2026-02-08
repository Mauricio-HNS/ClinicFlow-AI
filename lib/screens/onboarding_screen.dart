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
          const SizedBox(height: 24),
          const Expanded(
            child: _OnboardIllustration(),
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

class _OnboardIllustration extends StatelessWidget {
  const _OnboardIllustration();

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
            child: CustomPaint(
              painter: _IllustrationPainter(),
            ),
          ),
        );
      },
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final cardPaint = Paint()..color = AppColors.highlight;
    final blue = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = AppColors.clothing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final fillBlue = Paint()..color = AppColors.primary;
    final fillAccent = Paint()..color = AppColors.clothing;
    final redFill = Paint()..color = AppColors.furniture;
    final yellowFill = Paint()..color = AppColors.accent;

    // soft background card
    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24));
    canvas.drawRRect(rect, cardPaint);

    // floating bubbles
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), 10, bgPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 8, bgPaint);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.75), 12, bgPaint);

    // bike
    final bikeY = size.height * 0.64;
    final leftWheel = Offset(size.width * 0.28, bikeY);
    final rightWheel = Offset(size.width * 0.62, bikeY);
    canvas.drawCircle(leftWheel, 36, blue);
    canvas.drawCircle(rightWheel, 36, blue);
    canvas.drawLine(leftWheel, Offset(size.width * 0.45, bikeY - 36), blue);
    canvas.drawLine(Offset(size.width * 0.45, bikeY - 36), rightWheel, blue);
    canvas.drawLine(Offset(size.width * 0.45, bikeY - 36), Offset(size.width * 0.38, bikeY - 6), blue);
    canvas.drawLine(Offset(size.width * 0.45, bikeY - 36), Offset(size.width * 0.58, bikeY - 52), blue);
    canvas.drawLine(Offset(size.width * 0.58, bikeY - 52), Offset(size.width * 0.65, bikeY - 62), blue);

    // seller (left)
    final sellerHead = Offset(size.width * 0.18, size.height * 0.34);
    canvas.drawCircle(sellerHead, 14, redFill);
    canvas.drawLine(Offset(sellerHead.dx, sellerHead.dy + 16), Offset(size.width * 0.18, size.height * 0.52), blue);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.42), Offset(size.width * 0.32, size.height * 0.5), blue);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.52), Offset(size.width * 0.14, size.height * 0.64), blue);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.52), Offset(size.width * 0.26, size.height * 0.62), blue);

    // buyer (right)
    final buyerHead = Offset(size.width * 0.78, size.height * 0.34);
    canvas.drawCircle(buyerHead, 14, fillAccent);
    canvas.drawLine(Offset(buyerHead.dx, buyerHead.dy + 16), Offset(size.width * 0.78, size.height * 0.52), accent);
    canvas.drawLine(Offset(size.width * 0.78, size.height * 0.42), Offset(size.width * 0.64, size.height * 0.5), accent);
    canvas.drawLine(Offset(size.width * 0.78, size.height * 0.52), Offset(size.width * 0.72, size.height * 0.64), accent);
    canvas.drawLine(Offset(size.width * 0.78, size.height * 0.52), Offset(size.width * 0.86, size.height * 0.62), accent);

    // optional: keep the space clean (no banner/tag)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
