import 'package:flutter/material.dart';
import '../data/mock_sales.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              itemBuilder: (context, index) => _SaleListCard(
                title: mockSales[index].title,
                subtitle: '${mockSales[index].category} • ${mockSales[index].distance} • ${mockSales[index].date}',
                price: mockSales[index].price,
                color: mockSales[index].color,
                icon: mockSales[index].icon,
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: mockSales.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final Color color;
  final IconData icon;

  const _SaleListCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withValues(alpha: 0.16),
            ),
            child: Icon(icon, color: color),
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
          Text(price, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
