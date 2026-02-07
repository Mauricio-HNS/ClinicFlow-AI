import 'package:flutter/material.dart';

void main() {
  runApp(const GarageSaleApp());
}

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
        ),
      ),
      home: const AppShell(),
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

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GarageSale Madrid', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Vendas rápidas perto de você', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    CategoryChip(label: 'Móveis', color: AppColors.furniture),
                    SizedBox(width: 8),
                    CategoryChip(label: 'Roupas', color: AppColors.clothing),
                    SizedBox(width: 8),
                    CategoryChip(label: 'Eletrônicos', color: AppColors.electronics),
                    SizedBox(width: 8),
                    CategoryChip(label: 'Cozinha', color: AppColors.kitchen),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEFF2F4), Color(0xFFDCE4EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: MapGrid(),
                        ),
                        const Positioned(
                          left: 60,
                          top: 80,
                          child: MapPin(color: AppColors.furniture),
                        ),
                        const Positioned(
                          right: 80,
                          top: 120,
                          child: MapPin(color: AppColors.electronics),
                        ),
                        const Positioned(
                          left: 120,
                          bottom: 140,
                          child: MapPin(color: AppColors.clothing),
                        ),
                        const Positioned(
                          right: 120,
                          bottom: 90,
                          child: MapPin(color: AppColors.kitchen),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: AppColors.furniture.withValues(alpha: 0.18),
                                  ),
                                  child: const Icon(Icons.chair_alt_outlined, color: AppColors.furniture),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Sala completa + decoração', style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 4),
                                      Text('Hoje, 15:00 • 1.2 km • €45–€120', style: Theme.of(context).textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: const Text('Detalhes'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 88),
            ],
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 90,
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Criar venda rápida'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      SaleCardData('Sofá retrô + mesa', 'Móveis', '€90', '0.8 km', 'Hoje 11:00', AppColors.furniture, Icons.weekend_outlined),
      SaleCardData('Lote de roupas inverno', 'Roupas', '€4–€30', '1.6 km', 'Hoje 14:00', AppColors.clothing, Icons.checkroom_outlined),
      SaleCardData('TV + soundbar', 'Eletrônicos', '€140', '2.1 km', 'Amanhã 10:00', AppColors.electronics, Icons.tv_outlined),
      SaleCardData('Cozinha completa', 'Cozinha', '€6–€50', '2.8 km', 'Sáb 09:00', AppColors.kitchen, Icons.kitchen_outlined),
    ];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Text('Lista de vendas', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.swap_vert),
                  label: const Text('Distância'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: const [
                CategoryChip(label: 'Hoje', color: AppColors.primary),
                SizedBox(width: 8),
                CategoryChip(label: 'Até €50', color: AppColors.price),
                SizedBox(width: 8),
                CategoryChip(label: '1–3 km', color: AppColors.distance),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemBuilder: (context, index) => SaleListCard(data: items[index]),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}

class CreateSaleScreen extends StatelessWidget {
  const CreateSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Criar venda', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Cadastro rápido em 4 passos', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          const StepCard(
            step: '1/4',
            title: 'Cadastro rápido',
            subtitle: 'Nome, email e telefone',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          const StepCard(
            step: '2/4',
            title: 'Local + data',
            subtitle: 'Endereço aproximado, data e horário',
            icon: Icons.place_outlined,
          ),
          const SizedBox(height: 12),
          const StepCard(
            step: '3/4',
            title: 'Itens e fotos',
            subtitle: 'Upload rápido e descrição curta',
            icon: Icons.photo_library_outlined,
          ),
          const SizedBox(height: 12),
          const StepCard(
            step: '4/4',
            title: 'Destaque opcional',
            subtitle: '3€–10€ com Stripe ou PayPal',
            icon: Icons.star_border,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Começar agora'),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.highlight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pagamentos integrados e venda destacada com visibilidade extra no mapa.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      ('Venda destacada a 1 km', 'Sofá retrô com 30% off', Icons.star),
      ('Lembrete hoje às 15:00', 'Venda de roupas na sua área', Icons.alarm),
      ('Nova venda perto de você', 'Cozinha completa €8–€40', Icons.notifications_active),
    ];

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: notifications.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notificações', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Alertas de vendas próximas e destaques', style: Theme.of(context).textTheme.bodyMedium),
              ],
            );
          }
          final item = notifications[index - 1];
          return NotificationCard(title: item.$1, subtitle: item.$2, icon: item.$3);
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Meu perfil', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Clara Martinez', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('4.8 ⭐ • 230 pontos', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatTile(label: 'Vendas', value: '12')),
              const SizedBox(width: 12),
              Expanded(child: StatTile(label: 'Compras', value: '7')),
              const SizedBox(width: 12),
              Expanded(child: StatTile(label: 'Ranking', value: '#5')),
            ],
          ),
          const SizedBox(height: 20),
          Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const ProfileListItem(title: 'Vendas publicadas', subtitle: 'Última venda há 2 dias'),
          const ProfileListItem(title: 'Compras', subtitle: '3 compras concluídas este mês'),
          const ProfileListItem(title: 'Avaliações', subtitle: '9 avaliações recentes'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.highlight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Ranking semanal: mantenha sua posição e ganhe destaque grátis.', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const CategoryChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class MapPin extends StatelessWidget {
  final Color color;

  const MapPin({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 4,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class MapGrid extends StatelessWidget {
  const MapGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapGridPainter(),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SaleCardData {
  final String title;
  final String category;
  final String price;
  final String distance;
  final String date;
  final Color color;
  final IconData icon;

  const SaleCardData(
    this.title,
    this.category,
    this.price,
    this.distance,
    this.date,
    this.color,
    this.icon,
  );
}

class SaleListCard extends StatelessWidget {
  final SaleCardData data;

  const SaleListCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: data.color.withValues(alpha: 0.16),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${data.category} • ${data.distance} • ${data.date}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(data.price, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final IconData icon;

  const StepCard({super.key, required this.step, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$step • $title', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const NotificationCard({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class ProfileListItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const ProfileListItem({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const canvas = Color(0xFFF7F7F5);
  static const highlight = Color(0xFFEFF4FF);

  static const furniture = Color(0xFFEF4444);
  static const clothing = Color(0xFFF97316);
  static const electronics = Color(0xFF22C55E);
  static const kitchen = Color(0xFF14B8A6);

  static const price = Color(0xFF6D28D9);
  static const distance = Color(0xFF0EA5E9);
}
