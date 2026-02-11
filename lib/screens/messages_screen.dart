import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const chats = [
      ('Sofa retrô', 'Ainda esta disponivel?', '2m'),
      ('Studio Sol RH', 'Seu perfil combina com a vaga.', '14m'),
      ('Mercado Lavapies', 'Podemos marcar entrevista?', '32m'),
      ('Cozinha completa', 'Aceita retirada hoje?', '1h'),
    ];

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mensagens', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Converse com compradores e recrutadores em um so lugar.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            );
          }
          final chat = chats[index - 1];
          return GlassContainer(
            padding: const EdgeInsets.all(14),
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chat.$1, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(chat.$2, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(chat.$3, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemCount: chats.length + 1,
      ),
    );
  }
}
