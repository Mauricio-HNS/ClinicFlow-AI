import 'package:flutter/material.dart';
import '../state/notifications_state.dart';
import '../widgets/glass.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final baseNotifications = <AppNotificationItem>[
      const AppNotificationItem(title: 'Venda destacada a 1 km', subtitle: 'Sofá retrô com 30% off', icon: Icons.star),
      const AppNotificationItem(title: 'Lembrete hoje às 15:00', subtitle: 'Venda de roupas na sua área', icon: Icons.alarm),
      const AppNotificationItem(title: 'Nova venda perto de você', subtitle: 'Cozinha completa €8–€40', icon: Icons.notifications_active),
    ];

    return SafeArea(
      child: ValueListenableBuilder<List<AppNotificationItem>>(
        valueListenable: NotificationsState.items,
        builder: (context, dynamicItems, _) {
          final notifications = [...dynamicItems, ...baseNotifications];
          return ListView.separated(
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
              return _NotificationCard(title: item.title, subtitle: item.subtitle, icon: item.icon, color: item.color);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _NotificationCard({required this.title, required this.subtitle, required this.icon, required this.color});

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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
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
        ],
      ),
    );
  }
}
