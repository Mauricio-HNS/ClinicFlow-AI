import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/categories.dart';
import '../data/mock_sales.dart';
import '../models/sale.dart';
import '../search/semantic_search.dart';
import '../services/payments_api_client.dart';
import '../state/auth_session_state.dart';
import '../services/ai_api_client.dart';
import '../state/event_rewards_state.dart';
import '../state/favorites_state.dart';
import '../state/home_state.dart';
import 'create_sale_screen.dart';
import '../theme/app_colors.dart';
import '../utils/input_rules.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';

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
  int _searchRequestSeq = 0;

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
  bool get _hasCategoryFilter =>
      _selectedCategory != null && _selectedCategory!.isNotEmpty;
  List<Sale> get _categoryResults {
    if (!_hasCategoryFilter) return mockSales;
    final target = _normalize(_selectedCategory!);
    final filtered = mockSales
        .where((sale) {
          final category = _normalize(sale.category);
          final title = _normalize(sale.title);
          if (target == 'imoveis') return category.contains('imove');
          if (target == 'veiculos')
            return category.contains('veiculo') ||
                title.contains('carro') ||
                title.contains('moto');
          if (target == 'eletronicos e tecnologia')
            return category.contains('eletronico') ||
                title.contains('tv') ||
                title.contains('notebook');
          if (target == 'casa e jardim')
            return category.contains('cozinha') ||
                category.contains('moveis') ||
                title.contains('casa');
          if (target == 'moda e beleza')
            return category.contains('roupas') || title.contains('roupa');
          if (target == 'infantil')
            return title.contains('bebe') || title.contains('crianc');
          if (target == 'animais')
            return title.contains('pet') || title.contains('animal');
          if (target == 'esportes e lazer')
            return title.contains('bike') ||
                title.contains('lazer') ||
                title.contains('esporte');
          if (target == 'servicos')
            return title.contains('servico') || category.contains('servico');
          if (target == 'empregos')
            return title.contains('vaga') || category.contains('emprego');
          if (target == 'industria e negocios')
            return title.contains('industrial') || title.contains('negocio');
          return false;
        })
        .toList(growable: false);
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
                  Text(
                    'Descoberta rapida',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _HeroSearch(
                    cityLabel: _city,
                    controller: _searchController,
                    onSearchChanged: _applySemanticSearch,
                    onChangeCity: _openCityPicker,
                    onOpenAlerts: () =>
                        Navigator.pushNamed(context, '/search-alerts'),
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
                  Text(
                    'Categorias',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemBuilder: (context, index) {
                        final chip = _productQuickIntents[index];
                        return _SoftChip(
                          label: chip,
                          onTap: () {
                            _searchController.text = chip;
                            _searchController.selection =
                                TextSelection.fromPosition(
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
            SliverList.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                if (index == 2)
                  return const _HighlightBanner(
                    'Perto de voce',
                    'Achamos 12 resultados em ate 2 km',
                  );
                if (index == 8)
                  return const _HighlightBanner(
                    'Ofertas do dia',
                    'Precos caindo nas categorias mais buscadas',
                  );
                if (index == 15)
                  return const _HighlightBanner(
                    'Recomendados para voce',
                    'Feed ajustado pelo seu comportamento',
                  );
                final Sale sale = mockSales[index % mockSales.length];
                return _ProductCard(sale: sale);
              },
            ),
          if (_isSearching)
            SliverList.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) =>
                  _ProductCard(sale: _searchResults[index]),
            ),
          if (!_isSearching && _hasCategoryFilter)
            SliverList.builder(
              itemCount: _categoryResults.length,
              itemBuilder: (context, index) =>
                  _ProductCard(sale: _categoryResults[index]),
            ),
          if (!_isSearching && !_hasCategoryFilter)
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (_hasCategoryFilter)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Future<void> _applySemanticSearch(String query) async {
    final result = SemanticSaleSearch.searchSales(query, mockSales);
    final requestId = ++_searchRequestSeq;
    setState(() {
      _searchResults = result.sales;
      _searchSummary = result.summary;
    });

    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final remote = await AiApiClient.instance.semanticSearch(
      query: trimmed,
      city: _city,
      limit: 8,
    );
    if (!mounted || requestId != _searchRequestSeq || remote == null) {
      return;
    }

    final mapped = remote.hits.map(_mapRemoteHitToSale).toList(growable: false);
    if (mapped.isEmpty) {
      setState(() {
        _searchSummary = '${result.summary} (fallback local)';
      });
      return;
    }

    setState(() {
      _searchResults = mapped;
      _searchSummary =
          'Busca IA ativa: ${remote.normalizedIntent.isEmpty ? trimmed : remote.normalizedIntent}';
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

  Sale _mapRemoteHitToSale(RemoteSemanticHit hit) {
    final categoryLabel = _mapRemoteCategory(hit.category);
    final categoryData = allCategories.firstWhere(
      (item) => item.label == categoryLabel,
      orElse: () => allCategories.firstWhere(
        (item) => item.label == 'Outros',
        orElse: () => allCategories.first,
      ),
    );
    final now = DateTime.now();
    final minute = now.minute.toString().padLeft(2, '0');
    final priceText =
        '${hit.currency.toUpperCase()} ${hit.price.toStringAsFixed(hit.price % 1 == 0 ? 0 : 2)}';

    return Sale(
      id: hit.productId.isEmpty
          ? 'ai-${DateTime.now().microsecondsSinceEpoch}'
          : hit.productId,
      title: hit.title.isEmpty ? 'Sugestão IA' : hit.title,
      category: categoryLabel,
      price: priceText,
      distance: 'Resultado IA',
      date: 'Hoje, ${now.hour}:$minute',
      imageAsset: categoryCoverAssets[categoryLabel],
      imageUrl: categoryCoverUrls[categoryLabel],
      color: categoryData.color,
      icon: categoryData.icon,
      lat: 40.4168,
      lng: -3.7038,
      featured: hit.score >= 0.9,
    );
  }

  String _mapRemoteCategory(String rawCategory) {
    final normalized = _normalize(rawCategory);
    if (normalized.contains('eletron')) return 'Eletrônicos e Tecnologia';
    if (normalized.contains('casa') || normalized.contains('jardim')) {
      return 'Casa e Jardim';
    }
    if (normalized.contains('esporte')) return 'Esportes e Lazer';
    if (normalized.contains('imove')) return 'Imóveis';
    if (normalized.contains('veiculo')) return 'Veículos';
    if (normalized.contains('moda') || normalized.contains('beleza')) {
      return 'Moda e Beleza';
    }
    if (normalized.contains('servic')) return 'Serviços';
    if (normalized.contains('emprego')) return 'Empregos';
    if (normalized.contains('industria') || normalized.contains('negocio')) {
      return 'Indústria e Negócios';
    }
    return 'Outros';
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
                    city == _city
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: city == _city
                        ? AppColors.primary
                        : AppColors.textMuted,
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
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: AppInputRules.shortTextFormatters(maxLength: 90),
              maxLength: 90,
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
                  child: const Icon(
                    Icons.search,
                    color: AppColors.primaryEnd,
                    size: 20,
                  ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.55),
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(cityLabel, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              TextButton(
                onPressed: onChangeCity,
                child: const Text('Mudar cidade'),
              ),
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
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.76),
                  ),
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

class _SoftChipState extends State<_SoftChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeX;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    final ledHalo = accent.withValues(alpha: 0.2);
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.neumorphicBase,
                Color.alphaBlend(
                  accent.withValues(alpha: 0.12),
                  AppColors.neumorphicBase,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.alphaBlend(
                accent.withValues(alpha: 0.28),
                Colors.white.withValues(alpha: 0.72),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: ledHalo,
                blurRadius: 20,
                spreadRadius: -0.6,
                offset: const Offset(0, 3),
              ),
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
                      color: accent.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 0.24,
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

  String _sellerName(Sale sale) => 'Vendedor ${sale.id.padLeft(2, '0')}';

  String _sellerPhone(Sale sale) {
    final id = int.tryParse(sale.id) ?? 0;
    final suffix = (100000 + (id * 731) % 899999).toString();
    return '+34 6${suffix.substring(0, 2)} ${suffix.substring(2, 5)} ${suffix.substring(5)}';
  }

  void _showSaleDetails(BuildContext context) {
    final sellerName = _sellerName(sale);
    final sellerPhone = _sellerPhone(sale);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sale.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '${sale.category} • ${sale.distance}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                sale.price,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sellerName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sellerPhone,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mensagem enviada para $sellerName'),
                          ),
                        );
                      },
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Enviar mensagem',
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _contactSeller(BuildContext context) {
    final sellerName = _sellerName(sale);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mensagem enviada para $sellerName')),
    );
  }

  double _sellerRating(Sale sale) {
    final seed = int.tryParse(sale.id) ?? 1;
    return 4.2 + ((seed % 7) * 0.1);
  }

  int _sellerPoints(Sale sale) {
    final seed = int.tryParse(sale.id) ?? 1;
    return 120 + (seed * 13);
  }

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
              height: 186,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    sale.color.withValues(alpha: 0.45),
                    sale.color.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
                boxShadow: [
                  BoxShadow(
                    color: sale.color.withValues(alpha: 0.18),
                    blurRadius: 20,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    _SaleImage(
                      asset: sale.imageAsset,
                      url: sale.imageUrl,
                      icon: sale.icon,
                      color: sale.color,
                      iconSize: 62,
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.36),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.38),
                          ),
                        ),
                        child: Text(
                          sale.category,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: ValueListenableBuilder<Set<String>>(
                        valueListenable: FavoritesState.favoriteSaleIds,
                        builder: (context, favoriteIds, _) {
                          final isFavorite = favoriteIds.contains(sale.id);
                          return Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.94),
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              splashRadius: 18,
                              onPressed: () {
                                FavoritesState.toggleSale(sale);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFavorite
                                          ? 'Removido dos favoritos'
                                          : 'Adicionado aos favoritos',
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 20,
                                color: isFavorite
                                    ? AppColors.price
                                    : sale.color,
                              ),
                              tooltip: isFavorite
                                  ? 'Remover dos favoritos'
                                  : 'Favoritar anúncio',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  _sellerRating(sale).toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.emoji_events_outlined,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_sellerPoints(sale)} pts',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sale.price,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${sale.distance} • ${sale.date}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GradientButton(
                  onPressed: () => _showSaleDetails(context),
                  icon: Icons.info_outline_rounded,
                  label: 'Ver detalhes',
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                GradientButton(
                  onPressed: () => _contactSeller(context),
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Enviar mensagem',
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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

class _SaleImage extends StatelessWidget {
  final String? asset;
  final String? url;
  final IconData icon;
  final Color color;
  final double iconSize;

  const _SaleImage({
    required this.asset,
    required this.url,
    required this.icon,
    required this.color,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    if (image == null) return _fallback();

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.18),
                AppColors.primary.withValues(alpha: 0.10),
                Colors.black.withValues(alpha: 0.28),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildImage() {
    if (asset != null && asset!.isNotEmpty) {
      return Image.asset(
        asset!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }
    return null;
  }

  Widget _fallback() => Center(
    child: Icon(icon, size: iconSize, color: color),
  );
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
  if (key.contains('emprego') || key.contains('vaga'))
    return const Color(0xFF4D6BFF);
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

void _openEventInfoSheet(BuildContext rootContext) {
  showModalBottomSheet<void>(
    context: rootContext,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (context) {
      return ValueListenableBuilder<int>(
        valueListenable: EventRewardsState.freeEventCredits,
        builder: (context, credits, _) {
          return ValueListenableBuilder<int>(
            valueListenable: EventRewardsState.soldSales,
            builder: (context, soldSales, __) {
              final salesLeft = EventRewardsState.salesUntilNextReward();
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Criar Evento',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A cada 5 vendas concluídas você ganha 1 publicação de evento grátis.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.card_giftcard_outlined,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Créditos grátis: $credits • Vendas concluídas: $soldSales',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (credits > 0)
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(rootContext).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const CreateSaleScreen(
                                  isEvent: true,
                                  consumeEventCreditOnPublish: true,
                                  initialCategory: 'Serviços',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: const Text('Publicar evento grátis'),
                        )
                      else
                        Text(
                          'Faltam $salesLeft venda(s) para ganhar 1 evento grátis.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          final token = AuthSessionState.token.value;
                          if (token == null || token.isEmpty) {
                            _showHint(
                              rootContext,
                              'Faça login para iniciar pagamento do evento.',
                            );
                            return;
                          }

                          try {
                            final myPayments = await PaymentsApiClient.instance
                                .fetchMine(token);
                            PaymentRecordResult? lastPaid;
                            for (final payment in myPayments) {
                              if (payment.status == 'paid') {
                                lastPaid = payment;
                                break;
                              }
                            }

                            if (lastPaid != null) {
                              final paid = lastPaid;
                              if (!rootContext.mounted) return;
                              _showHint(
                                rootContext,
                                'Pagamento confirmado (${paid.currency} ${paid.amount.toStringAsFixed(2)}).',
                              );
                              Navigator.of(rootContext).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CreateSaleScreen(
                                    isEvent: true,
                                    initialCategory: 'Serviços',
                                    paidEventPaymentId: paid.id,
                                  ),
                                ),
                              );
                              return;
                            }

                            final checkout = await PaymentsApiClient.instance
                                .createEventCheckout(token);
                            if (checkout.provider == 'mock') {
                              await PaymentsApiClient.instance.confirmMock(
                                token,
                                checkout.paymentId,
                              );
                              if (!rootContext.mounted) return;
                              Navigator.of(rootContext).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CreateSaleScreen(
                                    isEvent: true,
                                    initialCategory: 'Serviços',
                                    paidEventPaymentId: checkout.paymentId,
                                  ),
                                ),
                              );
                              return;
                            }

                            if (checkout.provider == 'stripe' &&
                                checkout.checkoutUrl != null &&
                                checkout.checkoutUrl!.isNotEmpty) {
                              final uri = Uri.tryParse(checkout.checkoutUrl!);
                              if (uri == null) {
                                throw Exception('URL de checkout inválida.');
                              }
                              final opened = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              if (!opened) {
                                throw Exception(
                                  'Não foi possível abrir o checkout Stripe.',
                                );
                              }
                              if (!rootContext.mounted) return;
                              _showHint(
                                rootContext,
                                'Checkout Stripe aberto. Após concluir o pagamento, volte ao app e publique o evento.',
                              );
                              return;
                            }

                            if (!rootContext.mounted) return;
                            _showHint(
                              rootContext,
                              checkout.checkoutUrl == null
                                  ? 'Pagamento iniciado (${checkout.currency} ${checkout.amount.toStringAsFixed(2)}).'
                                  : 'Checkout criado. URL: ${checkout.checkoutUrl}',
                            );
                          } catch (error) {
                            if (!rootContext.mounted) return;
                            _showHint(
                              rootContext,
                              'Falha no pagamento: $error',
                            );
                          }
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
        },
      );
    },
  );
}
