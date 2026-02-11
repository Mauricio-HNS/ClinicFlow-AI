import 'package:flutter/material.dart';
import '../state/search_alert_state.dart';
import '../widgets/glass.dart';

class SearchAlertsScreen extends StatefulWidget {
  const SearchAlertsScreen({super.key});

  @override
  State<SearchAlertsScreen> createState() => _SearchAlertsScreenState();
}

class _SearchAlertsScreenState extends State<SearchAlertsScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ativar buscas'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alertas por satélite', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Digite o que você busca. Quando alguém publicar algo compatível, você recebe notificação.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Ex: notebook barato, sofá retrô, bike aro 29',
                  ),
                  onSubmitted: (_) => _addAlert(),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _addAlert,
                  icon: const Icon(Icons.satellite_alt_outlined),
                  label: const Text('Ativar alerta'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Buscas ativas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ValueListenableBuilder<List<SearchAlert>>(
            valueListenable: SearchAlertState.alerts,
            builder: (context, alerts, _) {
              if (alerts.isEmpty) {
                return GlassContainer(
                  padding: const EdgeInsets.all(14),
                  borderRadius: BorderRadius.circular(14),
                  child: Text('Nenhuma busca ativa ainda.', style: Theme.of(context).textTheme.bodyMedium),
                );
              }
              return Column(
                children: alerts
                    .map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          borderRadius: BorderRadius.circular(14),
                          child: Row(
                            children: [
                              const Icon(Icons.satellite_alt, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(alert.term, style: Theme.of(context).textTheme.bodyMedium)),
                              IconButton(
                                onPressed: () => SearchAlertState.removeAlert(alert),
                                icon: const Icon(Icons.close),
                                tooltip: 'Remover alerta',
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  void _addAlert() {
    final term = _controller.text.trim();
    if (term.isEmpty) return;
    SearchAlertState.addAlert(term);
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Busca ativada: "$term"')),
    );
  }
}
