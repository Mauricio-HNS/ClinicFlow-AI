import 'package:flutter/material.dart';
import '../data/mock_sales.dart';
import '../models/sale.dart';
import 'create_sale_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _city = 'Madrid, ES';

  final List<String> _productQuickIntents = const [
    'Carros',
    'Imoveis',
    'Eletronicos',
    'Entrega',
    'Usado',
    'Urgente',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Descoberta rapida', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _HeroSearch(
                    cityLabel: _city,
                    onChangeCity: _openCityPicker,
                    onOpenSell: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CreateSaleScreen(),
                        ),
                      );
                    },
                    onOpenEvent: () => _openEventInfoSheet(context),
                    onOpenJobs: () => Navigator.pushNamed(context, '/jobs'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final chip = _productQuickIntents[index];
                        return _SoftChip(
                          label: chip,
                          onTap: () => _showHint(context, 'Busca rapida: $chip'),
                        );
                      },
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemCount: _productQuickIntents.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _ConversionTag(title: 'Perto de voce'),
                  _ConversionTag(title: 'Ofertas do dia'),
                  _ConversionTag(title: 'Recomendados por IA'),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: 24,
            itemBuilder: (context, index) {
              if (index == 2) return const _HighlightBanner('Perto de voce', 'Achamos 12 resultados em ate 2 km');
              if (index == 8) return const _HighlightBanner('Ofertas do dia', 'Precos caindo nas categorias mais buscadas');
              if (index == 15) return const _HighlightBanner('Recomendados para voce', 'Feed ajustado pelo seu comportamento');
              final Sale sale = mockSales[index % mockSales.length];
              return _ProductCard(sale: sale);
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _openCityPicker() {
    const cities = [
      'Madrid, ES',
      'Barcelona, ES',
      'Valencia, ES',
      'Sevilla, ES',
      'Bilbao, ES',
      'Malaga, ES',
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                leading: Icon(Icons.location_city_outlined),
                title: Text('Escolha sua cidade'),
                subtitle: Text('Atualiza resultados e proximidade'),
              ),
              for (final city in cities)
                ListTile(
                  leading: Icon(
                    city == _city ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: city == _city ? AppColors.primary : AppColors.textMuted,
                  ),
                  title: Text(city),
                  onTap: () {
                    setState(() => _city = city);
                    Navigator.pop(context);
                    _showHint(this.context, 'Cidade alterada para $city');
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroSearch extends StatelessWidget {
  final String cityLabel;
  final VoidCallback onChangeCity;
  final VoidCallback onOpenSell;
  final VoidCallback onOpenEvent;
  final VoidCallback onOpenJobs;

  const _HeroSearch({
    required this.cityLabel,
    required this.onChangeCity,
    required this.onOpenSell,
    required this.onOpenEvent,
    required this.onOpenJobs,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            readOnly: true,
            onTap: () => _showHint(context, 'Busca semantica em construcao'),
            decoration: InputDecoration(
              hintText: 'O que voce procura? Produtos, carros ou casas?',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.highlight.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(cityLabel, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              TextButton(onPressed: onChangeCity, child: const Text('Mudar cidade')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenSell,
                  icon: const Icon(Icons.sell_outlined),
                  label: const Text('Vender'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenEvent,
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text('Criar Evento'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenJobs,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Empregos'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SoftChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Sale sale;

  const _ProductCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final badges = <String>[
      if (sale.featured) 'Novo',
      'Entrega',
      if (sale.id == '2') 'Urgente',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 178,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [sale.color.withValues(alpha: 0.45), sale.color.withValues(alpha: 0.12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(child: Icon(sale.icon, size: 62, color: sale.color)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: badges.map((badge) => _Badge(label: badge)).toList(),
            ),
            const SizedBox(height: 8),
            Text(sale.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              sale.price,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text('${sale.distance} • ${sale.date}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.highlight.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ConversionTag extends StatelessWidget {
  final String title;

  const _ConversionTag({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HighlightBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HighlightBanner(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 2),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        borderRadius: BorderRadius.circular(18),
        opacity: 0.18,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showHint(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void _openEventInfoSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Criar Evento', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Pacote promocional: 3€ para publicar ate 15 itens. Os itens entram no feed em ondas para manter visibilidade durante o dia.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showHint(context, 'Checkout de evento (3€) sera conectado em seguida.');
                },
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Publicar evento por 3€'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
