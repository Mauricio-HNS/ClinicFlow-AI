import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';
import '../state/profile_state.dart';
import '../state/reputation_state.dart';
import '../state/event_rewards_state.dart';
import 'create_sale_screen.dart';
import 'list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openMySales(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ListScreen()));
  }

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
              return GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(16),
                opacity: verified ? 0.28 : 0.2,
                child: Row(
                  children: [
                    Icon(
                      verified
                          ? Icons.verified_outlined
                          : Icons.warning_amber_outlined,
                      color: verified ? AppColors.primary : AppColors.clothing,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        verified
                            ? 'Perfil verificado'
                            : 'Complete seus dados para publicar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (!verified)
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/profile-verification',
                        ),
                        child: const Text('Completar'),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: ReputationState.points,
                    builder: (context, points, _) {
                      return ValueListenableBuilder<double>(
                        valueListenable: ReputationState.rating,
                        builder: (context, rating, __) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clara Martinez',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${rating.toStringAsFixed(1)} ⭐ • $points pontos',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Minhas vendas',
                  value: 'Painel',
                  onTap: () => _openMySales(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Evento grátis',
                  value: '5 vendas',
                  onTap: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Ranking',
                  value: '#5',
                  onTap: () => _showRankingSheet(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ProfileListItem(
            title: 'Minhas vendas',
            subtitle: 'Editar preço, fotos, status e remover anúncios',
            onTap: () => _openMySales(context),
          ),
          ProfileListItem(
            title: 'Publicar item',
            subtitle: 'Crie um novo anúncio para venda',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreateSaleScreen(),
                ),
              );
            },
          ),
          ProfileListItem(
            title: 'Avaliações',
            subtitle: '9 avaliações recentes',
            onTap: () => _showRatingsSheet(context),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<int>(
            valueListenable: EventRewardsState.freeEventCredits,
            builder: (context, credits, _) {
              return ValueListenableBuilder<int>(
                valueListenable: EventRewardsState.soldSales,
                builder: (context, soldSales, __) {
                  return GlassContainer(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Evento grátis: $credits crédito(s) • $soldSales/5 vendas para próximo bônus',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ranking semanal: mantenha sua posição e ganhe destaque grátis.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingsSheet(BuildContext context) {
    const ratings = [
      ('Ana', 'Vendedor super atencioso e pontual.', '5.0'),
      ('Luis', 'Produto exatamente como nas fotos.', '4.8'),
      ('Marta', 'Ótima comunicação durante a compra.', '4.9'),
    ];

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          itemCount: ratings.length + 1,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                'Avaliações recentes',
                style: Theme.of(context).textTheme.titleLarge,
              );
            }
            final item = ratings[index - 1];
            return GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.$2,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.$3} ⭐',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRankingSheet(BuildContext context) {
    const leaderboard = [
      ('Clara Martinez', '#5', '230 pts'),
      ('Diego Ramos', '#1', '412 pts'),
      ('Luna Costa', '#2', '378 pts'),
      ('Pablo Ruiz', '#3', '320 pts'),
      ('Sara Gomez', '#4', '288 pts'),
    ];

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          itemCount: leaderboard.length + 1,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                'Ranking semanal',
                style: Theme.of(context).textTheme.titleLarge,
              );
            }
            final item = leaderboard[index - 1];
            return GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      item.$2.replaceAll('#', ''),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    item.$3,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
