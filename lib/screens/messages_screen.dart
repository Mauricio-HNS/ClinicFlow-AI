import 'package:flutter/material.dart';
import '../services/messages_api_client.dart';
import '../state/auth_session_state.dart';
import '../theme/app_colors.dart';
import '../utils/input_rules.dart';
import '../widgets/glass.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<_ChatItem> _chats = <_ChatItem>[
    _ChatItem(
      id: 'local_1',
      title: 'Sofa retrô',
      preview: 'Ainda esta disponivel?',
      time: '2m',
      opened: false,
    ),
    _ChatItem(
      id: 'local_2',
      title: 'Studio Sol RH',
      preview: 'Seu perfil combina com a vaga.',
      time: '14m',
      opened: false,
    ),
    _ChatItem(
      id: 'local_3',
      title: 'Mercado Lavapies',
      preview: 'Podemos marcar entrevista?',
      time: '32m',
      opened: true,
    ),
    _ChatItem(
      id: 'local_4',
      title: 'Cozinha completa',
      preview: 'Aceita retirada hoje?',
      time: '1h',
      opened: true,
    ),
  ];

  int get _unreadCount => _chats.where((item) => !item.opened).length;
  int get _openedCount => _chats.where((item) => item.opened).length;

  @override
  void initState() {
    super.initState();
    _syncMine();
  }

  Future<void> _syncMine() async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) return;
    try {
      final remote = await MessagesApiClient.instance.fetchMine(token);
      if (!mounted || remote.isEmpty) return;
      setState(() {
        _chats
          ..clear()
          ..addAll(
            remote
                .map(
                  (item) => _ChatItem(
                    id: item.id,
                    title: item.title,
                    preview: item.preview,
                    time: item.timeLabel.isEmpty ? 'agora' : item.timeLabel,
                    opened: item.opened,
                  ),
                )
                .toList(growable: false),
          );
      });
    } catch (_) {
      // Keep local fallback chats.
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              opacity: 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.glow.withValues(alpha: 0.34),
                              blurRadius: 14,
                              spreadRadius: 0.1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          color: AppColors.primaryEnd,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mensagens',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Converse com compradores e recrutadores em um so lugar.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TopPill(
                        label: 'Nao lidas: $_unreadCount',
                        active: _unreadCount > 0,
                      ),
                      _TopPill(label: 'Abertas: $_openedCount', active: false),
                      _TopPill(label: 'Total: ${_chats.length}', active: false),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_chats.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _confirmDeleteAll(context),
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Apagar todas'),
                    ),
                ],
              ),
            );
          }
          if (_chats.isEmpty) {
            return GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nenhuma conversa no momento.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quando chegar uma nova mensagem, ela aparece aqui com destaque.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          final chat = _chats[index - 1];
          final unread = !chat.opened;
          final ledColor = const Color(0xFF22C55E);

          return Dismissible(
            key: ValueKey('${chat.title}_${chat.time}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFB42318), Color(0xFFD92D20)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete_outline_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Apagar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (_) => _confirmDeleteOne(context, chat),
            onDismissed: (_) {
              _removeRemote(chat.id);
              setState(() => _chats.remove(chat));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Conversa com "${chat.title}" apagada.'),
                ),
              );
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (!chat.opened) {
                  setState(() => chat.opened = true);
                  _markOpenRemote(chat.id);
                }
                _openReplySheet(context, chat);
              },
              child: GlassContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: BorderRadius.circular(18),
                opacity: unread ? 0.22 : 0.16,
                tint: unread
                    ? AppColors.surface.withValues(alpha: 0.94)
                    : AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neumorphicLightShadow,
                    blurRadius: 20,
                    spreadRadius: 0.8,
                    offset: const Offset(-6, -6),
                  ),
                  BoxShadow(
                    color: AppColors.neumorphicDarkShadow,
                    blurRadius: 24,
                    spreadRadius: 1.0,
                    offset: const Offset(8, 9),
                  ),
                  if (unread)
                    BoxShadow(
                      color: ledColor.withValues(alpha: 0.22),
                      blurRadius: 16,
                      spreadRadius: 0.2,
                      offset: const Offset(0, 2),
                    ),
                ],
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: unread
                            ? ledColor.withValues(alpha: 0.16)
                            : AppColors.surface.withValues(alpha: 0.48),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: unread
                            ? [
                                BoxShadow(
                                  color: ledColor.withValues(alpha: 0.45),
                                  blurRadius: 14,
                                  spreadRadius: 0.2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: unread
                            ? const Color(0xFF15803D)
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chat.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              if (unread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: ledColor,
                                    borderRadius: BorderRadius.circular(99),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ledColor.withValues(alpha: 0.6),
                                        blurRadius: 8,
                                        spreadRadius: 0.2,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            chat.preview,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: unread
                                      ? AppColors.textPrimary.withValues(
                                          alpha: 0.86,
                                        )
                                      : AppColors.textMuted,
                                  fontWeight: unread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chat.time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: unread
                            ? const Color(0xFF166534)
                            : AppColors.textMuted,
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: unread
                          ? const Color(0xFF166534)
                          : AppColors.textMuted.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemCount: (_chats.isEmpty ? 1 : _chats.length) + 1,
      ),
    );
  }

  Future<bool> _confirmDeleteOne(BuildContext context, _ChatItem chat) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apagar conversa'),
            content: Text('Deseja apagar a conversa com "${chat.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Apagar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apagar todas'),
            content: const Text('Deseja apagar todas as conversas?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Apagar tudo'),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldDelete) return;
    setState(() => _chats.clear());
    _removeAllRemote();
  }

  void _openReplySheet(BuildContext context, _ChatItem chat) {
    var message = '';
    showModalBottomSheet<void>(
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
            24 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Responder ${chat.title}',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              TextField(
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: AppInputRules.longTextFormatters(
                  maxLength: 280,
                ),
                maxLength: 280,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  hintText: 'Escreva sua resposta',
                ),
                onChanged: (value) => message = value,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (message.trim().isEmpty) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(
                          content: Text('Escreva uma mensagem para responder.'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(sheetContext);
                    _createRemoteMessage(
                      title: chat.title,
                      preview: message.trim(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Resposta enviada para ${chat.title}.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Enviar resposta'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markOpenRemote(String messageId) async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty || messageId.startsWith('local_')) {
      return;
    }
    try {
      await MessagesApiClient.instance.markOpened(token, messageId);
    } catch (_) {}
  }

  Future<void> _removeRemote(String messageId) async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty || messageId.startsWith('local_')) {
      return;
    }
    try {
      await MessagesApiClient.instance.remove(token, messageId);
    } catch (_) {}
  }

  Future<void> _removeAllRemote() async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) return;
    try {
      await MessagesApiClient.instance.removeAll(token);
    } catch (_) {}
  }

  Future<void> _createRemoteMessage({
    required String title,
    required String preview,
  }) async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) return;
    try {
      await MessagesApiClient.instance.create(
        token: token,
        title: title,
        preview: preview,
        timeLabel: 'agora',
        opened: true,
      );
    } catch (_) {}
  }
}

class _TopPill extends StatelessWidget {
  final String label;
  final bool active;

  const _TopPill({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF22C55E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.74),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 10,
                  spreadRadius: 0.2,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: active ? const Color(0xFF166534) : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChatItem {
  final String id;
  final String title;
  final String preview;
  final String time;
  bool opened;

  _ChatItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.time,
    required this.opened,
  });
}
