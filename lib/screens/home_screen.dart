import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../data/mock_sales.dart';
import '../models/sale.dart';
import '../search/semantic_search.dart';
import '../state/home_state.dart';
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
  final TextEditingController _searchController = TextEditingController();
  List<Sale> _searchResults = const [];
  String _searchSummary = '';
  String? _selectedCategory;

  final List<String> _productQuickIntents = const [
    'Imóveis',
    'Veículos',
    'Eletrônicos e Tecnologia',
    'Casa e Jardim',
    'Moda e Beleza',
    'Infantil',
    'Animais',
    'Esportes e Lazer',
    'Serviços',
    'Empregos',
    'Indústria e Negócios',
    'Outros',
  ];

  bool get _isSearching => _searchController.text.trim().isNotEmpty;
  bool get _hasCategoryFilter => _selectedCategory != null && _selectedCategory!.isNotEmpty;
  List<Sale> get _categoryResults {
    if (!_hasCategoryFilter) return mockSales;
    final target = _normalize(_selectedCategory!);
    final filtered = mockSales.where((sale) {
      final category = _normalize(sale.category);
      final title = _normalize(sale.title);
      if (target == 'imoveis') return category.contains('imove');
      if (target == 'veiculos') return category.contains('veiculo') || title.contains('carro') || title.contains('moto');
      if (target == 'eletronicos e tecnologia') return category.contains('eletronico') || title.contains('tv') || title.contains('notebook');
      if (target == 'casa e jardim') return category.contains('cozinha') || category.contains('moveis') || title.contains('casa');
      if (target == 'moda e beleza') return category.contains('roupas') || title.contains('roupa');
      if (target == 'infantil') return title.contains('bebe') || title.contains('crianc');
      if (target == 'animais') return title.contains('pet') || title.contains('animal');
      if (target == 'esportes e lazer') return title.contains('bike') || title.contains('lazer') || title.contains('esporte');
      if (target == 'servicos') return title.contains('servico') || category.contains('servico');
      if (target == 'empregos') return title.contains('vaga') || category.contains('emprego');
      if (target == 'industria e negocios') return title.contains('industrial') || title.contains('negocio');
      return false;
    }).toList(growable: false);
    return filtered.isEmpty ? mockSales : filtered;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = HomeState.selectedCategory.value;
    HomeState.selectedCategory.addListener(_syncCategoryFilter);
  }

  @override
  void dispose() {
    HomeState.selectedCategory.removeListener(_syncCategoryFilter);
    _searchController.dispose();
    super.dispose();
  }

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
                    controller: _searchController,
                    onSearchChanged: _applySemanticSearch,
                    onChangeCity: _openCityPicker,
                    onOpenAlerts: () => Navigator.pushNamed(context, '/search-alerts'),
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
                  Text('Categorias', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final chip = _productQuickIntents[index];
                        return _SoftChip(
                          label: chip,
                          onTap: () {
                            _searchController.text = chip;
                            _searchController.selection = TextSelection.fromPosition(
                              TextPosition(offset: chip.length),
                            );
                            _applySemanticSearch(chip);
                          },
                        );
                      },
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemCount: _productQuickIntents.length,
                    ),
                  ),
                  if (_hasCategoryFilter) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InputChip(
                        label: Text('Categoria: $_selectedCategory'),
                        selected: true,
                        onDeleted: _clearCategoryFilter,
                        deleteIcon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          if (_isSearching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _searchSummary,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isSearching && !_hasCategoryFilter)
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
          if (!_isSearching && !_hasCategoryFilter)
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
          if (_isSearching)
            SliverList.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) => _ProductCard(sale: _searchResults[index]),
            ),
          if (!_isSearching && _hasCategoryFilter)
            SliverList.builder(
              itemCount: _categoryResults.length,
              itemBuilder: (context, index) => _ProductCard(sale: _categoryResults[index]),
            ),
          if (!_isSearching && !_hasCategoryFilter)
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (_hasCategoryFilter)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  void _applySemanticSearch(String query) {
    final result = SemanticSaleSearch.searchSales(query, mockSales);
    setState(() {
      _searchResults = result.sales;
      _searchSummary = result.summary;
    });
  }

  void _syncCategoryFilter() {
    if (!mounted) return;
    setState(() => _selectedCategory = HomeState.selectedCategory.value);
  }

  void _clearCategoryFilter() {
    HomeState.selectedCategory.value = null;
    setState(() => _selectedCategory = null);
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
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
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onChangeCity;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenSell;
  final VoidCallback onOpenEvent;
  final VoidCallback onOpenJobs;

  const _HeroSearch({
    required this.cityLabel,
    required this.controller,
    required this.onSearchChanged,
    required this.onChangeCity,
    required this.onOpenAlerts,
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neumorphicLightShadow,
                  blurRadius: 12,
                  offset: const Offset(-5, -5),
                ),
                BoxShadow(
                  color: AppColors.neumorphicDarkShadow,
                  blurRadius: 14,
                  spreadRadius: 0.8,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Ex: notebook barato para programar',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neumorphicBase,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neumorphicLightShadow,
                        blurRadius: 6,
                        offset: const Offset(-2, -2),
                      ),
                      BoxShadow(
                        color: AppColors.neumorphicDarkShadow,
                        blurRadius: 7,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.search, color: AppColors.primaryEnd, size: 20),
                ),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          controller.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: AppColors.neumorphicBase,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.55), width: 1.3),
                ),
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
              const SizedBox(width: 6),
              IconButton(
                onPressed: onOpenAlerts,
                icon: const Icon(Icons.satellite_alt_outlined),
                tooltip: 'Ativar buscas',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TopActionButton(
                  onPressed: onOpenSell,
                  icon: CupertinoIcons.tag,
                  label: 'Vender',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TopActionButton(
                  onPressed: onOpenEvent,
                  icon: CupertinoIcons.calendar,
                  label: 'Criar Evento',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TopActionButton(
                  onPressed: onOpenJobs,
                  icon: CupertinoIcons.folder,
                  label: 'Empregos',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _TopActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: SizedBox(
        height: 96,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.neumorphicBase,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.76)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neumorphicLightShadow,
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                    BoxShadow(
                      color: AppColors.neumorphicDarkShadow,
                      blurRadius: 12,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: AppColors.primaryEnd, size: 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SoftChip({required this.label, required this.onTap});

  @override
  State<_SoftChip> createState() => _SoftChipState();
}

class _SoftChipState extends State<_SoftChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeX;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -1.0), weight: 24),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 28),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -0.5), weight: 18),
      TweenSequenceItem(tween: Tween(begin: -0.5, end: 0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || _controller.isAnimating) return;
      _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _chipAccent(widget.label);
    return AnimatedBuilder(
      animation: _shakeX,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeX.value, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.neumorphicBase,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neumorphicLightShadow,
                blurRadius: 11,
                offset: const Offset(-5, -5),
              ),
              BoxShadow(
                color: AppColors.neumorphicDarkShadow,
                blurRadius: 14,
                spreadRadius: 0.6,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 7,
                      spreadRadius: 0.4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: sale.imageUrl == null
                    ? Center(child: Icon(sale.icon, size: 62, color: sale.color))
                    : Image.network(
                        sale.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Center(child: Icon(sale.icon, size: 62, color: sale.color)),
                      ),
              ),
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
    final accent = _chipAccent(title);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.32),
            accent.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.35),
            blurRadius: 7,
            offset: const Offset(-1, -1),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.32),
            blurRadius: 9,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

Color _chipAccent(String value) {
  final key = value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c');
  if (key.contains('imove')) return const Color(0xFF4F8DFF);
  if (key.contains('veiculo')) return const Color(0xFF7C5CFF);
  if (key.contains('eletron')) return const Color(0xFF00A5D8);
  if (key.contains('casa')) return const Color(0xFF28B67E);
  if (key.contains('moda')) return const Color(0xFFE47AA7);
  if (key.contains('infantil')) return const Color(0xFFFFB347);
  if (key.contains('animais')) return const Color(0xFF8A6E5A);
  if (key.contains('esporte')) return const Color(0xFF23A0A2);
  if (key.contains('servico')) return const Color(0xFFFF9E57);
  if (key.contains('emprego') || key.contains('vaga')) return const Color(0xFF4D6BFF);
  if (key.contains('industria')) return const Color(0xFF7384A8);
  if (key.contains('outros')) return const Color(0xFF5F6B7A);
  if (key.contains('ofertas')) return const Color(0xFFFF8E72);
  if (key.contains('recomendados')) return const Color(0xFF8F63E8);
  return AppColors.primary;
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
