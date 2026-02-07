import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/mock_sales.dart';
import '../models/sale.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Sale? _selected;

  @override
  Widget build(BuildContext context) {
    final markers = mockSales
        .map(
          (sale) => Marker(
            markerId: MarkerId(sale.id),
            position: LatLng(sale.lat, sale.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(_hueForCategory(sale.category)),
            onTap: () => setState(() => _selected = sale),
          ),
        )
        .toSet();

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GarageSale Madrid', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Vendas rápidas perto de você', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      CategoryChip(label: 'Móveis', color: AppColors.furniture),
                      SizedBox(width: 8),
                      CategoryChip(label: 'Roupas', color: AppColors.clothing),
                      SizedBox(width: 8),
                      CategoryChip(label: 'Eletrônicos', color: AppColors.electronics),
                      SizedBox(width: 8),
                      CategoryChip(label: 'Cozinha', color: AppColors.kitchen),
                      SizedBox(width: 8),
                      CategoryChip(label: 'Misc', color: AppColors.misc),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(40.421, -3.703),
                        zoom: 13.2,
                      ),
                      markers: markers,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) => _controller.complete(controller),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 88),
            ],
          ),
          if (_selected != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _selected!.color.withValues(alpha: 0.18),
                      ),
                      child: Icon(_selected!.icon, color: _selected!.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selected!.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('${_selected!.date} • ${_selected!.distance} • ${_selected!.price}', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Detalhes'),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 90,
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Criar venda rápida'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _hueForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'móveis':
        return BitmapDescriptor.hueRed;
      case 'roupas':
        return BitmapDescriptor.hueOrange;
      case 'eletrônicos':
        return BitmapDescriptor.hueGreen;
      case 'cozinha':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }
}
