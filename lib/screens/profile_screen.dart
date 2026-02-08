import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../state/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Meu perfil', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ValueListenableBuilder<bool>(
            valueListenable: ProfileState.isVerified,
            builder: (context, verified, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: verified ? AppColors.highlight : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      verified ? Icons.verified_outlined : Icons.warning_amber_outlined,
                      color: verified ? AppColors.primary : AppColors.clothing,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        verified ? 'Perfil verificado' : 'Complete seus dados para publicar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (!verified)
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/profile-verification'),
                        child: const Text('Completar'),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Clara Martinez', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('4.8 ⭐ • 230 pontos', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: StatTile(label: 'Vendas', value: '12')),
              SizedBox(width: 12),
              Expanded(child: StatTile(label: 'Compras', value: '7')),
              SizedBox(width: 12),
              Expanded(child: StatTile(label: 'Ranking', value: '#5')),
            ],
          ),
          const SizedBox(height: 20),
          Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const ProfileListItem(title: 'Vendas publicadas', subtitle: 'Última venda há 2 dias'),
          const ProfileListItem(title: 'Compras', subtitle: '3 compras concluídas este mês'),
          const ProfileListItem(title: 'Avaliações', subtitle: '9 avaliações recentes'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.highlight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Ranking semanal: mantenha sua posição e ganhe destaque grátis.', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
