import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppNotificationItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const AppNotificationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = AppColors.primary,
  });
}

class NotificationsState {
  static final ValueNotifier<List<AppNotificationItem>> items = ValueNotifier<List<AppNotificationItem>>([]);

  static void addSearchMatch({
    required String term,
    required String listingTitle,
  }) {
    final item = AppNotificationItem(
      title: 'Alerta de busca: "$term"',
      subtitle: 'Novo anúncio encontrado: $listingTitle',
      icon: Icons.satellite_alt,
      color: AppColors.primaryEnd,
    );
    items.value = [item, ...items.value];
  }

  static void addJobApplication({
    required String jobTitle,
    required String candidateName,
  }) {
    final item = AppNotificationItem(
      title: 'Nova candidatura recebida',
      subtitle: '$candidateName se inscreveu em "$jobTitle"',
      icon: Icons.person_add_alt_1_rounded,
      color: AppColors.primary,
    );
    items.value = [item, ...items.value];
  }
}
