import 'package:flutter/material.dart';

import '../data/mock_sales.dart';
import '../models/sale.dart';
import '../state/published_sales_state.dart';
import '../state/favorites_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Sale>>(
      valueListenable: PublishedSalesState.sales,
      builder: (context, publishedSales, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: FavoritesState.favoriteSaleIds,
          builder: (context, favoriteIds, __) {
            final salesById = <String, Sale>{};
            for (final sale in mockSales.followedBy(publishedSales)) {
              salesById[sale.id] = sale;
            }
            final favorites = favoriteIds
                .map((id) => salesById[id])
                .whereType<Sale>()
                .toList(growable: false);

            return SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/home');
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                              tooltip: 'Voltar',
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Favoritos',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Acompanhe produtos e vagas salvos.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    );
                  }
                  if (favorites.isEmpty) {
                    return GlassContainer(
                      borderRadius: BorderRadius.circular(18),
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'Sem favoritos no momento. Toque no coração em um anúncio para salvar.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  final sale = favorites[index - 1];
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
                              Text(
                                sale.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${sale.distance} • ${sale.date}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            FavoritesState.removeSale(sale.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Removido dos favoritos: ${sale.title}',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.favorite,
                            color: AppColors.price,
                          ),
                          tooltip: 'Desfavoritar',
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemCount: favorites.isEmpty ? 2 : favorites.length + 1,
              ),
            );
          },
        );
      },
    );
  }
}
