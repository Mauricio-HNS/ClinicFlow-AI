import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

class CategoryDetailScreen extends StatelessWidget {
  final CategoryItem category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.label),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            tint: category.color.withValues(alpha: 0.22),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(category.icon, color: category.color, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.label, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(category.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Subcategorias', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...category.subcategories.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 18, color: category.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('Ações rápidas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  label: const Text('Ver anúncios'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Home'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
