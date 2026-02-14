import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../state/auth_session_state.dart';
import '../state/event_rewards_state.dart';
import '../state/profile_state.dart';
import '../state/reputation_state.dart';
import '../theme/app_colors.dart';
import '../utils/input_rules.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';
import 'create_sale_screen.dart';
import 'list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  void _openMySales() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ListScreen()));
  }

  Future<void> _changeAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    ProfileState.updateAvatar(bytes);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto de perfil atualizada com sucesso.')),
    );
  }

  Future<void> _editBasicDataSheet() async {
    final nameController = TextEditingController(text: ProfileState.name.value);
    final emailController = TextEditingController(
      text: ProfileState.email.value,
    );
    final phoneController = TextEditingController(
      text: ProfileState.phone.value,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar perfil',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                inputFormatters: AppInputRules.nameFormatters(),
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                inputFormatters: AppInputRules.emailFormatters(),
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: AppInputRules.phoneFormatters(),
                maxLength: 17,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final nameValidation = AppInputRules.name(
                      nameController.text,
                    );
                    final emailValidation = AppInputRules.email(
                      emailController.text,
                    );
                    final phoneValidation = AppInputRules.phone(
                      phoneController.text,
                    );
                    final firstError =
                        nameValidation ?? emailValidation ?? phoneValidation;
                    if (firstError != null) {
                      ScaffoldMessenger.of(
                        sheetContext,
                      ).showSnackBar(SnackBar(content: Text(firstError)));
                      return;
                    }
                    ProfileState.updateBasicData(
                      updatedName: nameController.text,
                      updatedEmail: emailController.text,
                      updatedPhone: phoneController.text,
                    );
                    Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar alterações'),
                ),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Meu perfil',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton.icon(
                onPressed: _editBasicDataSheet,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildVerificationBanner(context),
          const SizedBox(height: 12),
          _buildIdentityCard(context),
          const SizedBox(height: 14),
          _buildStatsRow(context),
          const SizedBox(height: 16),
          _buildRewardProgress(context),
          const SizedBox(height: 18),
          Text(
            'Gestão da conta',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ProfileListItem(
            title: 'Painel Minhas vendas',
            subtitle: 'Acompanhar, editar, pausar, vender e remover anúncios',
            onTap: _openMySales,
          ),
          ProfileListItem(
            title: 'Publicar novo item',
            subtitle: 'Criar um anúncio para venda',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreateSaleScreen(),
                ),
              );
            },
          ),
          ProfileListItem(
            title: 'Verificação do perfil',
            subtitle: 'Documento e selfie para liberar publicação',
            onTap: () => Navigator.pushNamed(context, '/profile-verification'),
          ),
          ProfileListItem(
            title: 'Avaliações recebidas',
            subtitle: 'Notas e comentários dos compradores',
            onTap: () => _showRatingsSheet(context),
          ),
          ProfileListItem(
            title: 'Sair da conta',
            subtitle: 'Encerrar sessão neste dispositivo',
            onTap: _logout,
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ranking semanal e reputação influenciam destaque dos seus anúncios.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => _showRankingSheet(context),
                  child: const Text('Ver ranking'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ProfileState.isVerified,
      builder: (context, verified, _) {
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(18),
          opacity: verified ? 0.32 : 0.23,
          child: Row(
            children: [
              Icon(
                verified ? Icons.verified_outlined : Icons.pending_actions,
                color: verified ? const Color(0xFF1F9E49) : AppColors.clothing,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  verified
                      ? 'Conta verificada. Você pode publicar e gerenciar seus anúncios normalmente.'
                      : 'Conta pendente de verificação. Complete para publicar sem bloqueio.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!verified)
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/profile-verification'),
                  child: const Text('Completar'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdentityCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          ValueListenableBuilder<Uint8List?>(
            valueListenable: ProfileState.avatarBytes,
            builder: (context, avatar, _) {
              return Stack(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.16),
                    backgroundImage: avatar != null
                        ? MemoryImage(avatar)
                        : null,
                    child: avatar == null
                        ? const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 34,
                          )
                        : null,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: InkWell(
                      onTap: _changeAvatar,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.neumorphicBase,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: ProfileState.name,
                  builder: (context, name, _) => Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<String>(
                  valueListenable: ProfileState.email,
                  builder: (context, email, _) => Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                ValueListenableBuilder<String>(
                  valueListenable: ProfileState.phone,
                  builder: (context, phone, _) =>
                      Text(phone, style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _changeAvatar,
            child: const Text('Trocar foto'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ReputationState.points,
      builder: (context, points, _) {
        return ValueListenableBuilder<double>(
          valueListenable: ReputationState.rating,
          builder: (context, rating, _) {
            return ValueListenableBuilder<int>(
              valueListenable: EventRewardsState.freeEventCredits,
              builder: (context, credits, _) {
                return Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Minhas vendas',
                        value: 'Painel',
                        onTap: _openMySales,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        label: 'Reputação',
                        value: '${rating.toStringAsFixed(1)} ⭐',
                        onTap: () => _showRatingsSheet(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        label: 'Créditos',
                        value: '$credits',
                        onTap: () => _showRankingSheet(context),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRewardProgress(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: EventRewardsState.soldSales,
      builder: (context, soldSales, _) {
        final step = soldSales % 5;
        final progress = step / 5;

        return GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Text(
                    'Meta para evento grátis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    '$step/5',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF22C55E),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A cada 5 vendas concluídas, 1 crédito entra automaticamente para publicar evento grátis.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
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

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sair da conta?'),
          content: const Text('Deseja realmente encerrar sua sessão neste dispositivo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;
    await AuthSessionState.clearPersisted();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
  }
}
