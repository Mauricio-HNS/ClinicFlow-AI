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
          childAspectRatio: 0.95,
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
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 30),
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
