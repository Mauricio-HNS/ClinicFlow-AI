import 'package:flutter/material.dart';
import '../data/mock_sales.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          final sale = mockSales[(index - 1) % mockSales.length];
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
                const Icon(Icons.favorite, color: AppColors.price),
              ],
            ),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemCount: 9,
      ),
    );
  }
}
