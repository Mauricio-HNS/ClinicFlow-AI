import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/sale.dart';
import 'create_sale_screen.dart';
import '../state/event_rewards_state.dart';
import '../state/published_sales_state.dart';
import '../state/reputation_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';

enum _SaleStatus { active, paused, sold }

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late List<Sale> _sales;
  final Set<String> _selectedSaleIds = <String>{};
  final Map<String, _SaleStatus> _statusBySaleId = <String, _SaleStatus>{};
  final ImagePicker _picker = ImagePicker();

  _SaleStatus? _statusFilter;
  bool _sortPriceAsc = false;

  @override
  void initState() {
    super.initState();
    _sales = List<Sale>.from(PublishedSalesState.sales.value);
    PublishedSalesState.sales.addListener(_syncPublishedSales);
    _ensureStatuses();
  }

  void _syncPublishedSales() {
    if (!mounted) return;
    setState(() {
      _sales = List<Sale>.from(PublishedSalesState.sales.value);
      _selectedSaleIds.removeWhere(
        (id) => !_sales.any((sale) => sale.id == id),
      );
      _ensureStatuses();
    });
  }

  void _ensureStatuses() {
    for (final sale in _sales) {
      _statusBySaleId.putIfAbsent(sale.id, () {
        final id = int.tryParse(sale.id) ?? 0;
        if (id % 5 == 0) return _SaleStatus.sold;
        if (id % 3 == 0) return _SaleStatus.paused;
        _statusBySaleId[sale.id] = _SaleStatus.active;
        return _SaleStatus.active;
      });
    }
    _statusBySaleId.removeWhere(
      (saleId, _) => !_sales.any((sale) => sale.id == saleId),
    );
  }

  @override
  void dispose() {
    PublishedSalesState.sales.removeListener(_syncPublishedSales);
    super.dispose();
  }

  List<Sale> get _filteredSales {
    final filtered = _sales.where((sale) {
      final status = _statusBySaleId[sale.id] ?? _SaleStatus.active;
      if (_statusFilter != null && status != _statusFilter) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      final aPrice = _extractMaxPrice(a.price) ?? 0;
      final bPrice = _extractMaxPrice(b.price) ?? 0;
      return _sortPriceAsc
          ? aPrice.compareTo(bPrice)
          : bPrice.compareTo(aPrice);
    });

    return filtered;
  }

  bool get _areAllFilteredSelected {
    final current = _filteredSales;
    if (current.isEmpty) return false;
    return current.every((sale) => _selectedSaleIds.contains(sale.id));
  }

  int get _activeCount =>
      _statusBySaleId.values.where((s) => s == _SaleStatus.active).length;
  int get _pausedCount =>
      _statusBySaleId.values.where((s) => s == _SaleStatus.paused).length;
  int get _soldCount =>
      _statusBySaleId.values.where((s) => s == _SaleStatus.sold).length;

  double? _extractMaxPrice(String raw) {
    final matches = RegExp(
      r'\d[\d.,]*',
    ).allMatches(raw).map((m) => m.group(0)!).toList();
    if (matches.isEmpty) return null;

    final values = matches
        .map(
          (value) =>
              double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')),
        )
        .whereType<double>()
        .toList();

    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

  String _sellerName(Sale sale) => 'Vendedor ${sale.id.padLeft(2, '0')}';

  void _showSaleDetails(Sale sale) {
    final status = _statusBySaleId[sale.id] ?? _SaleStatus.active;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sale.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _StatusBadge(status: status),
              const SizedBox(height: 8),
              Text(
                '${sale.category} • ${sale.distance} • ${sale.date}',
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
              const SizedBox(height: 14),
              GradientButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendMessage(sale);
                },
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Enviar mensagem',
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(Sale sale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mensagem enviada para ${_sellerName(sale)}')),
    );
  }

  void _toggleSelectAllFiltered() {
    final current = _filteredSales;
    if (current.isEmpty) return;

    setState(() {
      if (_areAllFilteredSelected) {
        for (final sale in current) {
          _selectedSaleIds.remove(sale.id);
        }
      } else {
        for (final sale in current) {
          _selectedSaleIds.add(sale.id);
        }
      }
    });
  }

  void _deleteOne(Sale sale) {
    setState(() {
      PublishedSalesState.removeSale(sale.id);
      _selectedSaleIds.remove(sale.id);
      _statusBySaleId.remove(sale.id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Item "${sale.title}" apagado')));
  }

  void _deleteSelected() {
    if (_selectedSaleIds.isEmpty) return;

    final deletedCount = _selectedSaleIds.length;
    final saleIdsToDelete = _selectedSaleIds.toList(growable: false);
    setState(() {
      for (final saleId in saleIdsToDelete) {
        PublishedSalesState.removeSale(saleId);
        _statusBySaleId.remove(saleId);
      }
      _selectedSaleIds.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$deletedCount item(ns) apagado(s)')),
    );
  }

  void _togglePause(Sale sale) {
    final status = _statusBySaleId[sale.id] ?? _SaleStatus.active;

    setState(() {
      if (status == _SaleStatus.paused) {
        _statusBySaleId[sale.id] = _SaleStatus.active;
      } else if (status == _SaleStatus.active) {
        _statusBySaleId[sale.id] = _SaleStatus.paused;
      }
    });
  }

  void _markAsSold(Sale sale) {
    if ((_statusBySaleId[sale.id] ?? _SaleStatus.active) == _SaleStatus.sold) {
      return;
    }
    setState(() {
      _statusBySaleId[sale.id] = _SaleStatus.sold;
    });
    ReputationState.addSoldSalePoints();
    final earnedCredit = EventRewardsState.registerSoldSale();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          earnedCredit
              ? 'Você ganhou 1 evento grátis! 🎉'
              : 'Venda concluída! Faltam ${EventRewardsState.salesUntilNextReward()} para ganhar evento grátis.',
        ),
      ),
    );
  }

  List<int> _buildFunnelSteps() {
    final total = _sales.length;
    final active = _activeCount;
    final sold = _soldCount;
    final draft = math.max(total + 2, 2);
    return <int>[draft, active, sold];
  }

  Future<void> _editSale(Sale sale) async {
    final titleController = TextEditingController(text: sale.title);
    final priceController = TextEditingController(text: sale.price);
    final List<String> editablePhotos = List<String>.from(sale.photoPaths);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickPhoto() async {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (picked == null) return;
              setModalState(() => editablePhotos.add(picked.path));
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar anúncio',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ex: Geladeira frost free',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        hintText: 'Ex: R\$ 1.200',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Fotos (${editablePhotos.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: pickPhoto,
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: const Text('Adicionar'),
                        ),
                      ],
                    ),
                    if (editablePhotos.isEmpty)
                      Text(
                        'Nenhuma foto adicionada.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: editablePhotos
                            .map((path) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(path),
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 88,
                                              height: 88,
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setModalState(
                                          () => editablePhotos.remove(path),
                                        );
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            })
                            .toList(growable: false),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final updatedSale = sale.copyWith(
                                title: titleController.text.trim().isEmpty
                                    ? sale.title
                                    : titleController.text.trim(),
                                price: priceController.text.trim().isEmpty
                                    ? sale.price
                                    : priceController.text.trim(),
                                photoPaths: List<String>.from(editablePhotos),
                                date: 'Atualizado agora',
                              );
                              PublishedSalesState.updateSale(updatedSale);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Anúncio atualizado com sucesso.',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Salvar alterações'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sales = _filteredSales;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    tooltip: 'Voltar',
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minhas vendas',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${_sales.length} anúncio(s) criado(s)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  GradientButton(
                    label: _sortPriceAsc ? 'Preço ↑' : 'Preço ↓',
                    icon: Icons.swap_vert,
                    height: 36,
                    radius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    iconSize: 20,
                    iconContainerSize: 32,
                    onPressed: () =>
                        setState(() => _sortPriceAsc = !_sortPriceAsc),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(18),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: EventRewardsState.soldSales,
                      builder: (context, soldSales, _) {
                        return ValueListenableBuilder<int>(
                          valueListenable: EventRewardsState.freeEventCredits,
                          builder: (context, freeCredits, __) {
                            final soldProgress = soldSales % 5;
                            final reachedBonus =
                                soldProgress == 0 && soldSales > 0;
                            final progress = reachedBonus
                                ? 1.0
                                : soldProgress / 5;

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Crédito para evento grátis',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 240,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.neumorphicBase,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: reachedBonus
                                              ? Colors.green.withValues(
                                                  alpha: 0.35,
                                                )
                                              : Colors.white.withValues(
                                                  alpha: 0.82,
                                                ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                AppColors.neumorphicLightShadow,
                                            blurRadius: 8,
                                            offset: const Offset(-3, -3),
                                          ),
                                          BoxShadow(
                                            color:
                                                AppColors.neumorphicDarkShadow,
                                            blurRadius: 10,
                                            offset: const Offset(4, 4),
                                          ),
                                          if (reachedBonus)
                                            BoxShadow(
                                              color: Colors.green.withValues(
                                                alpha: 0.24,
                                              ),
                                              blurRadius: 10,
                                              spreadRadius: 0.1,
                                            ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.emoji_events_rounded,
                                            size: 16,
                                            color: reachedBonus
                                                ? Colors.amber.shade700
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$freeCredits crédito(s)',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: reachedBonus
                                                      ? Colors.green.shade700
                                                      : AppColors.textMuted,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppColors.neumorphicBase,
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neumorphicLightShadow,
                                        blurRadius: 6,
                                        offset: const Offset(-2, -2),
                                      ),
                                      BoxShadow(
                                        color: AppColors.neumorphicDarkShadow,
                                        blurRadius: 8,
                                        offset: const Offset(3, 3),
                                      ),
                                    ],
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width =
                                          constraints.maxWidth * progress;
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
                                          width: width < 10 ? 10 : width,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            gradient: LinearGradient(
                                              colors: reachedBonus
                                                  ? [
                                                      Colors.green.shade400,
                                                      Colors.green.shade600,
                                                    ]
                                                  : [
                                                      AppColors.primary,
                                                      AppColors.primaryEnd,
                                                    ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    (reachedBonus
                                                            ? Colors.green
                                                            : AppColors.primary)
                                                        .withValues(
                                                          alpha: 0.28,
                                                        ),
                                                blurRadius: 10,
                                                spreadRadius: 0.2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      '$soldProgress/5 vendas',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      reachedBonus
                                          ? 'Troféu aceso: crédito entrou na conta'
                                          : 'Ao completar 5, ganha 1 crédito',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _TopStat(
                          label: 'Ativas',
                          value: _activeCount.toString(),
                          color: AppColors.primary,
                        ),
                        _TopStat(
                          label: 'Pausadas',
                          value: _pausedCount.toString(),
                          color: AppColors.price,
                        ),
                        _TopStat(
                          label: 'Vendidas',
                          value: _soldCount.toString(),
                          color: Colors.green.shade600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evolucao do funil',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rascunho -> Ativo -> Vendido',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 98,
                      child: _MiniFunnelChart(steps: _buildFunnelSteps()),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: ValueListenableBuilder<int>(
                valueListenable: ReputationState.points,
                builder: (context, points, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: ReputationState.rating,
                    builder: (context, rating, __) {
                      return GlassContainer(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber),
                            const SizedBox(width: 6),
                            Text(
                              rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.emoji_events_outlined,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$points pts',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              'Reputacao',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: _statusFilter == null,
                    onTap: () => setState(() => _statusFilter = null),
                  ),
                  _FilterChip(
                    label: 'Ativos',
                    selected: _statusFilter == _SaleStatus.active,
                    onTap: () =>
                        setState(() => _statusFilter = _SaleStatus.active),
                  ),
                  _FilterChip(
                    label: 'Pausados',
                    selected: _statusFilter == _SaleStatus.paused,
                    onTap: () =>
                        setState(() => _statusFilter = _SaleStatus.paused),
                  ),
                  _FilterChip(
                    label: 'Vendidos',
                    selected: _statusFilter == _SaleStatus.sold,
                    onTap: () =>
                        setState(() => _statusFilter = _SaleStatus.sold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GradientButton(
                    label: _areAllFilteredSelected
                        ? 'Desmarcar tudo'
                        : 'Selecionar tudo',
                    icon: _areAllFilteredSelected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    height: 36,
                    radius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    iconSize: 20,
                    iconContainerSize: 32,
                    onPressed: _toggleSelectAllFiltered,
                  ),
                  GradientButton(
                    label: _selectedSaleIds.isEmpty
                        ? 'Apagar selecionados'
                        : 'Apagar (${_selectedSaleIds.length})',
                    icon: Icons.delete_outline_rounded,
                    height: 36,
                    radius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    iconSize: 20,
                    iconContainerSize: 32,
                    onPressed: _selectedSaleIds.isEmpty
                        ? null
                        : _deleteSelected,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _sales.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(18),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sell_outlined,
                                color: AppColors.primary,
                                size: 30,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Você ainda não publicou itens para venda.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const CreateSaleScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_box_outlined),
                                label: const Text('Publicar um item'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : sales.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(18),
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            'Nenhum item encontrado para os filtros atuais.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: sales.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        final status =
                            _statusBySaleId[sale.id] ?? _SaleStatus.active;

                        return _SaleListCard(
                          sale: sale,
                          status: status,
                          isSelected: _selectedSaleIds.contains(sale.id),
                          onToggleSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSaleIds.add(sale.id);
                              } else {
                                _selectedSaleIds.remove(sale.id);
                              }
                            });
                          },
                          onShowDetails: () => _showSaleDetails(sale),
                          onSendMessage: () => _sendMessage(sale),
                          onEdit: () => _editSale(sale),
                          onTogglePause: () => _togglePause(sale),
                          onMarkSold: () => _markAsSold(sale),
                          onDelete: () => _deleteOne(sale),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TopStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.neumorphicBase,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.85),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neumorphicLightShadow,
              blurRadius: 8,
              offset: const Offset(-3, -3),
            ),
            BoxShadow(
              color: AppColors.neumorphicDarkShadow,
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
            if (selected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 8,
                spreadRadius: 0.3,
              ),
          ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? AppColors.primaryEnd : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _SaleStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;

    switch (status) {
      case _SaleStatus.active:
        label = 'Ativo';
        color = AppColors.primary;
        break;
      case _SaleStatus.paused:
        label = 'Pausado';
        color = AppColors.price;
        break;
      case _SaleStatus.sold:
        label = 'Vendido';
        color = Colors.green.shade600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SaleListCard extends StatelessWidget {
  final Sale sale;
  final _SaleStatus status;
  final bool isSelected;
  final ValueChanged<bool> onToggleSelected;
  final VoidCallback onShowDetails;
  final VoidCallback onSendMessage;
  final VoidCallback onEdit;
  final VoidCallback onTogglePause;
  final VoidCallback onMarkSold;
  final VoidCallback onDelete;

  const _SaleListCard({
    required this.sale,
    required this.status,
    required this.isSelected,
    required this.onToggleSelected,
    required this.onShowDetails,
    required this.onSendMessage,
    required this.onEdit,
    required this.onTogglePause,
    required this.onMarkSold,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSold = status == _SaleStatus.sold;
    final bool isPaused = status == _SaleStatus.paused;

    return GlassContainer(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(14),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withValues(alpha: 0.12),
          blurRadius: 16,
          spreadRadius: 0.4,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.neumorphicLightShadow,
          blurRadius: 18,
          spreadRadius: 0.6,
          offset: const Offset(-5, -5),
        ),
        BoxShadow(
          color: AppColors.neumorphicDarkShadow,
          blurRadius: 20,
          spreadRadius: 0.8,
          offset: const Offset(6, 7),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => onToggleSelected(!isSelected),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.55),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: sale.color.withValues(alpha: 0.16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: sale.photoPaths.isNotEmpty
                      ? Image.file(
                          File(sale.photoPaths.first),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            if (sale.imageAsset != null) {
                              return Image.asset(
                                sale.imageAsset!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(sale.icon, color: sale.color),
                              );
                            }
                            return Icon(sale.icon, color: sale.color);
                          },
                        )
                      : sale.imageAsset != null
                      ? Image.asset(
                          sale.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(sale.icon, color: sale.color),
                        )
                      : Icon(sale.icon, color: sale.color),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sale.category} • ${sale.distance} • ${sale.date}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    _StatusBadge(status: status),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 96,
                child: Text(
                  sale.price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GradientButton(
                onPressed: onShowDetails,
                icon: Icons.info_outline_rounded,
                label: 'Detalhes',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                iconSize: 20,
                iconContainerSize: 32,
              ),
              GradientButton(
                onPressed: onSendMessage,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Mensagem',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                iconSize: 20,
                iconContainerSize: 32,
              ),
              GradientButton(
                onPressed: onEdit,
                icon: Icons.edit_outlined,
                label: 'Editar',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                iconSize: 20,
                iconContainerSize: 32,
              ),
              GradientButton(
                onPressed: isSold ? null : onTogglePause,
                icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: isPaused ? 'Reativar' : 'Pausar',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                iconSize: 20,
                iconContainerSize: 32,
              ),
              GradientButton(
                onPressed: isSold ? null : onMarkSold,
                icon: Icons.check_circle_outline_rounded,
                label: 'Vendido',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                iconSize: 20,
                iconContainerSize: 32,
              ),
              GradientButton(
                onPressed: onDelete,
                icon: Icons.delete_outline_rounded,
                label: 'Apagar',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                iconSize: 20,
                iconContainerSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniFunnelChart extends StatelessWidget {
  final List<int> steps;

  const _MiniFunnelChart({required this.steps});

  @override
  Widget build(BuildContext context) {
    final maxValue = steps.fold<int>(1, (prev, e) => e > prev ? e : prev);
    final labels = <String>['Rascunho', 'Ativo', 'Vendido'];

    return LayoutBuilder(
      builder: (context, constraints) {
        const reservedHeight = 36.0;
        final maxBarHeight = math.max(
          16.0,
          constraints.maxHeight - reservedHeight,
        );
        const minBarHeight = 6.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List<Widget>.generate(steps.length, (index) {
            final value = steps[index];
            final factor = value / maxValue;
            final barHeight =
                minBarHeight + (factor * (maxBarHeight - minBarHeight));
            final isSold = index == 2;
            final color = isSold ? Colors.green.shade500 : AppColors.primary;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == steps.length - 1 ? 0 : 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            color.withValues(alpha: 0.85),
                            color.withValues(alpha: 0.35),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.22),
                            blurRadius: 8,
                            spreadRadius: 0.2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
