import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

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
        separatorBuilder: (_, index) => const SizedBox(height: 12),
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
          return _NotificationCard(title: item.$1, subtitle: item.$2, icon: item.$3);
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _NotificationCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
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
