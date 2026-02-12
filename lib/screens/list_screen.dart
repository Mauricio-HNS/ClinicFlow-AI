import 'package:flutter/material.dart';

import '../data/mock_sales.dart';
import '../models/sale.dart';
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
  final List<Sale> _sales = List<Sale>.from(mockSales);
  final Set<String> _selectedSaleIds = <String>{};
  final Map<String, _SaleStatus> _statusBySaleId = <String, _SaleStatus>{};
  final TextEditingController _searchController = TextEditingController();

  _SaleStatus? _statusFilter;
  bool _sortPriceAsc = false;

  @override
  void initState() {
    super.initState();
    for (final sale in _sales) {
      final id = int.tryParse(sale.id) ?? 0;
      if (id % 5 == 0) {
        _statusBySaleId[sale.id] = _SaleStatus.sold;
      } else if (id % 3 == 0) {
        _statusBySaleId[sale.id] = _SaleStatus.paused;
      } else {
        _statusBySaleId[sale.id] = _SaleStatus.active;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Sale> get _filteredSales {
    final query = _normalize(_searchController.text);
    final filtered = _sales.where((sale) {
      final status = _statusBySaleId[sale.id] ?? _SaleStatus.active;
      if (_statusFilter != null && status != _statusFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final haystack = _normalize(
        '${sale.title} ${sale.category} ${sale.price}',
      );
      return haystack.contains(query);
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
      _sales.removeWhere((item) => item.id == sale.id);
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
    setState(() {
      _sales.removeWhere((sale) => _selectedSaleIds.contains(sale.id));
      for (final saleId in _selectedSaleIds) {
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
    setState(() {
      _statusBySaleId[sale.id] = _SaleStatus.sold;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sales = _filteredSales;

    return SafeArea(
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
                  child: Text(
                    'Vendas publicadas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                GradientButton(
                  label: _sortPriceAsc ? 'Preço ↑' : 'Preço ↓',
                  icon: Icons.swap_vert,
                  height: 36,
                  radius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
              child: Row(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Buscar por título, categoria ou preço',
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
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
                  onTap: () => setState(() => _statusFilter = _SaleStatus.sold),
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
                  onPressed: _selectedSaleIds.isEmpty ? null : _deleteSelected,
                ),
              ],
            ),
          ),
          Expanded(
            child: sales.isEmpty
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
                              Icons.inventory_2_outlined,
                              color: AppColors.primary,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhuma venda encontrada para esse filtro.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: sales.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
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
                        onTogglePause: () => _togglePause(sale),
                        onMarkSold: () => _markAsSold(sale),
                        onDelete: () => _deleteOne(sale),
                      );
                    },
                  ),
          ),
        ],
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
                  child: sale.imageAsset != null
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
              ),
              GradientButton(
                onPressed: onSendMessage,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Mensagem',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              GradientButton(
                onPressed: isSold ? null : onTogglePause,
                icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: isPaused ? 'Reativar' : 'Pausar',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              GradientButton(
                onPressed: isSold ? null : onMarkSold,
                icon: Icons.check_circle_outline_rounded,
                label: 'Vendido',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              GradientButton(
                onPressed: onDelete,
                icon: Icons.delete_outline_rounded,
                label: 'Apagar',
                height: 34,
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
