import 'package:flutter/material.dart';
import '../data/mock_sales.dart';
import '../models/sale.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final List<Sale> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = List<Sale>.from(mockSales);
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _favorites.length + 1;
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Favoritos', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Acompanhe produtos e vagas salvos.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            );
          }
          if (_favorites.isEmpty) {
            return GlassContainer(
              borderRadius: BorderRadius.circular(18),
              padding: const EdgeInsets.all(14),
              child: Text('Sem favoritos no momento.', style: Theme.of(context).textTheme.bodyMedium),
            );
          }
          final sale = _favorites[index - 1];
          return GlassContainer(
            borderRadius: BorderRadius.circular(18),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: sale.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(sale.icon, color: sale.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sale.title, style: Theme.of(context).textTheme.titleMedium),
                      Text('${sale.distance} • ${sale.date}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeFavorite(sale),
                  icon: const Icon(Icons.favorite, color: AppColors.price),
                  tooltip: 'Desfavoritar',
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemCount: itemCount,
      ),
    );
  }

  void _removeFavorite(Sale sale) {
    setState(() => _favorites.remove(sale));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removido dos favoritos: ${sale.title}')),
    );
  }
}
