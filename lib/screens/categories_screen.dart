import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as categorias'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final item = allCategories[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/category', arguments: item),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(18),
              tint: item.color.withValues(alpha: 0.24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 92,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _CategoryCover(label: item.label),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.08),
                                  item.color.withValues(alpha: 0.14),
                                  Colors.black.withValues(alpha: 0.24),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.icon, color: item.color, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(item.label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.84),
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Ver anúncios',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: item.color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCover extends StatelessWidget {
  final String label;

  const _CategoryCover({required this.label});

  @override
  Widget build(BuildContext context) {
    final asset = categoryCoverAssets[label];

    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }
    return const SizedBox.shrink();
  }
}
