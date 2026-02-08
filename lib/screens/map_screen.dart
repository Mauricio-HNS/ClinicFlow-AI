import 'package:flutter/material.dart';
import '../data/mock_sales.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Vender agora'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GarageSale Madrid', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    const _SearchBar(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Madrid • 2 km', style: Theme.of(context).textTheme.bodyMedium),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.tune, size: 18),
                          label: const Text('Filtros'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          CategoryChip(label: '€ Preço', color: AppColors.price),
                          SizedBox(width: 8),
                          CategoryChip(label: 'Distância', color: AppColors.distance),
                          SizedBox(width: 8),
                          CategoryChip(label: 'Hoje', color: AppColors.primary),
                          SizedBox(width: 8),
                          CategoryChip(label: 'Com foto', color: AppColors.kitchen),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Categorias', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 92,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _CategoryShortcut(label: 'Móveis', color: AppColors.furniture, icon: Icons.chair_alt_outlined),
                          _CategoryShortcut(label: 'Roupas', color: AppColors.clothing, icon: Icons.checkroom_outlined),
                          _CategoryShortcut(label: 'Eletrônicos', color: AppColors.electronics, icon: Icons.tv_outlined),
                          _CategoryShortcut(label: 'Cozinha', color: AppColors.kitchen, icon: Icons.kitchen_outlined),
                          _CategoryShortcut(label: 'Bikes', color: AppColors.misc, icon: Icons.directions_bike_outlined),
                          _CategoryShortcut(label: 'Decoração', color: AppColors.price, icon: Icons.home_outlined),
                          _CategoryShortcut(label: 'Brinquedos', color: AppColors.accent, icon: Icons.toys_outlined),
                          _CategoryShortcut(label: 'Livros', color: AppColors.primary, icon: Icons.menu_book_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _MicroCard(
                      title: '3 novos anúncios do que você buscou',
                      subtitle: 'Sofás, mesas e luminárias perto de você.',
                    ),
                    const SizedBox(height: 18),
                    Text('Feed principal', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final sale = mockSales[index % mockSales.length];
                  if (index == 2) {
                    return const _NearbyNow();
                  }
                  if (index == 5) {
                    return const _RecommendationSection();
                  }
                  if (index == 8) {
                    return const _ChatPreview();
                  }
                  return _FeedCard(sale: sale);
                },
                childCount: 12,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('Buscar móveis, roupas, eletrônicos…', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CategoryShortcut({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final dynamic sale;

  const _FeedCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: sale.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Icon(sale.icon, size: 52, color: sale.color)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(sale.title, style: Theme.of(context).textTheme.titleMedium)),
                Text(sale.price, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 6),
            Text('${sale.category} • ${sale.distance} • ${sale.date}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('Detalhes')),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Chat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyNow extends StatelessWidget {
  const _NearbyNow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perto de você agora', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text('Mini mapa', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: mockSales
                  .map(
                    (sale) => Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 14,
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
                              color: sale.color.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(sale.icon, color: sale.color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(sale.title, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(sale.distance, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achamos que você vai gostar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...mockSales.take(2).map((sale) => _FeedCard(sale: sale)),
        ],
      ),
    );
  }
}

class _MicroCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MicroCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on_outlined, color: AppColors.primary),
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

class _ChatPreview extends StatelessWidget {
  const _ChatPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chat recente', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('“Ainda está disponível?” • 2 novas mensagens', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Abrir')),
          ],
        ),
      ),
    );
  }
}
