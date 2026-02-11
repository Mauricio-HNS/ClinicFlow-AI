import 'package:flutter/material.dart';
import '../data/mock_jobs.dart';
import '../data/mock_sales.dart';
import '../models/job.dart';
import '../models/sale.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';

enum DiscoveryMode { products, jobs }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DiscoveryMode _mode = DiscoveryMode.products;
  bool _deliveryOnly = false;
  bool _urgentOnly = false;
  String _city = 'Madrid, ES';

  final List<String> _productQuickIntents = const [
    'Carros',
    'Imoveis',
    'Eletronicos',
    'Entrega',
    'Usado',
    'Urgente',
  ];

  final List<String> _jobQuickIntents = const [
    'Freelance',
    'Remoto',
    'Part-time',
    'TI',
    'Vendas',
    'Saude',
  ];

  final List<String> _productFilters = const [
    'Preco',
    'Distancia',
    'Condicao',
    'Entrega',
    'Urgente',
  ];

  final List<String> _jobFilters = const [
    'Salario minimo',
    'Remoto/Hibrido',
    'Contrato',
    'Senioridade',
    'Area',
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
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final chip = _quickIntents[index];
                        return _SoftChip(
                          label: chip,
                          onTap: () => _showHint(context, 'Busca rapida: $chip'),
                        );
                      },
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemCount: _quickIntents.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              height: 122,
              child: Container(
                color: AppColors.canvas,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  children: [
                    _ModeSwitch(
                      mode: _mode,
                      onChanged: (mode) => setState(() => _mode = mode),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _activeFilters.length + 1,
                        separatorBuilder: (_, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == _activeFilters.length) {
                            return _SoftChip(
                              label: 'Ordenar',
                              icon: Icons.swap_vert,
                              onTap: () => _openSortSheet(context),
                            );
                          }
                          final label = _activeFilters[index];
                          return _FilterChipButton(
                            label: label,
                            selected: _isSelectedFilter(label),
                            onTap: () => _toggleFilter(label),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ConversionTag(title: 'Perto de voce'),
                  _ConversionTag(title: 'Ofertas do dia'),
                  _ConversionTag(title: 'Vagas em alta'),
                  _ConversionTag(title: 'Recomendados por IA'),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: 30,
            itemBuilder: (context, index) {
              if (index == 2) return const _HighlightBanner('Perto de voce', 'Achamos 12 resultados em ate 2 km');
              if (index == 7) return const _HighlightBanner('Ofertas do dia', 'Precos caindo nas categorias mais buscadas');
              if (index == 14) return const _HighlightBanner('Vagas em alta', 'Candidatura rapida com perfil pre-preenchido');
              if (index == 22) return const _HighlightBanner('Recomendados para voce', 'Feed ajustado pelo seu comportamento');
              if (_mode == DiscoveryMode.products) {
                final Sale sale = mockSales[index % mockSales.length];
                return _ProductCard(sale: sale);
              }
              final Job job = mockJobs[index % mockJobs.length];
              return _JobCard(job: job);
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  List<String> get _activeFilters => _mode == DiscoveryMode.products ? _productFilters : _jobFilters;
  List<String> get _quickIntents => _mode == DiscoveryMode.products ? _productQuickIntents : _jobQuickIntents;

  bool _isSelectedFilter(String label) {
    if (label == 'Entrega') return _deliveryOnly;
    if (label == 'Urgente') return _urgentOnly;
    return false;
  }

  void _toggleFilter(String label) {
    if (label == 'Entrega') {
      setState(() => _deliveryOnly = !_deliveryOnly);
      return;
    }
    if (label == 'Urgente') {
      setState(() => _urgentOnly = !_urgentOnly);
      return;
    }
    _showHint(context, 'Filtro: $label');
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
                subtitle: Text('Atualiza resultados, filtros e proximidade'),
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

  const _HeroSearch({
    required this.cityLabel,
    required this.onChangeCity,
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
              hintText: 'O que voce procura? Produtos, carros, casas ou empregos?',
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
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final DiscoveryMode mode;
  final ValueChanged<DiscoveryMode> onChanged;

  const _ModeSwitch({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Produtos',
              icon: Icons.shopping_cart_outlined,
              selected: mode == DiscoveryMode.products,
              onTap: () => onChanged(DiscoveryMode.products),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Empregos',
              icon: Icons.work_outline,
              selected: mode == DiscoveryMode.jobs,
              onTap: () => onChanged(DiscoveryMode.jobs),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.26) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? AppColors.textPrimary : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _SoftChip({required this.label, required this.onTap, this.icon});

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
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 6),
            ],
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.3) : AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
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

class _JobCard extends StatelessWidget {
  final Job job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final modeLabel = job.remote ? 'Remoto' : 'Hibrido/Presencial';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.apartment_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.company, style: Theme.of(context).textTheme.bodyMedium),
                      Text(job.title, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(label: job.salary),
                _Badge(label: job.type),
                _Badge(label: modeLabel),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text('${job.location} • ${job.posted}', style: Theme.of(context).textTheme.bodyMedium)),
                FilledButton.icon(
                  onPressed: () => _showHint(context, 'Aplicacao enviada em 1 toque'),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Aplicar'),
                ),
              ],
            ),
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

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}

void _openSortSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Relevancia'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: const Text('Proximidade'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Mais recentes'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

void _showHint(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
