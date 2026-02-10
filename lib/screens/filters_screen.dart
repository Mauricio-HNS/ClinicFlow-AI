import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  double _maxPrice = 500;
  double _distance = 10;
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
            max: 10000,
            divisions: 50,
            label: _maxPrice >= 10000 ? '∞' : '€${_maxPrice.round()}',
            onChanged: (value) => setState(() => _maxPrice = value),
            activeColor: AppColors.primary,
          ),
          Text(_maxPrice >= 10000 ? '∞' : '€${_maxPrice.round()}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text('Distância', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _distance,
            min: 1,
            max: 300,
            divisions: 299,
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
          GradientButton(
            label: 'Aplicar filtros',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
          GradientButton(
            label: 'Limpar',
            onPressed: () {
              setState(() {
                _maxPrice = 500;
                _distance = 10;
                _todayOnly = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
