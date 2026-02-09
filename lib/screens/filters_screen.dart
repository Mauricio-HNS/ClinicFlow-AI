import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  double _maxPrice = 200;
  double _distance = 5;
  bool _todayOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Preço máximo', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _maxPrice,
            min: 10,
            max: 2000,
            divisions: 20,
            label: '€${_maxPrice.round()}',
            onChanged: (value) => setState(() => _maxPrice = value),
            activeColor: AppColors.primary,
          ),
          Text('€${_maxPrice.round()}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text('Distância', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _distance,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${_distance.round()} km',
            onChanged: (value) => setState(() => _distance = value),
            activeColor: AppColors.primary,
          ),
          Text('${_distance.round()} km', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _todayOnly,
            onChanged: (value) => setState(() => _todayOnly = value),
            title: const Text('Somente hoje'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52)),
            child: const Text('Aplicar filtros'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _maxPrice = 200;
                _distance = 5;
                _todayOnly = false;
              });
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}
