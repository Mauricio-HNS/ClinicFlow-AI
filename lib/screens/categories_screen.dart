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
          childAspectRatio: 1.2,
        ),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final item = allCategories[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Abrir categoria: ${item.label}')),
              );
            },
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 26),
                  ),
                  const Spacer(),
                  Text(item.label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Ver anúncios', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
