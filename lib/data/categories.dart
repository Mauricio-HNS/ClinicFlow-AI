import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  final Color color;

  const CategoryItem({required this.label, required this.icon, required this.color});
}

const coreCategories = <CategoryItem>[
  CategoryItem(label: 'Veículos', icon: Icons.directions_car_outlined, color: AppColors.misc),
  CategoryItem(label: 'Imóveis', icon: Icons.home_outlined, color: AppColors.price),
  CategoryItem(label: 'Eletrônicos', icon: Icons.devices_outlined, color: AppColors.electronics),
  CategoryItem(label: 'Casa e Jardim', icon: Icons.chair_alt_outlined, color: AppColors.furniture),
  CategoryItem(label: 'Empregos', icon: Icons.work_outline, color: AppColors.primary),
  CategoryItem(label: 'Serviços', icon: Icons.handyman_outlined, color: AppColors.kitchen),
  CategoryItem(label: 'Moda', icon: Icons.checkroom_outlined, color: AppColors.clothing),
  CategoryItem(label: 'Esportes', icon: Icons.sports_soccer_outlined, color: AppColors.distance),
];

const allCategories = <CategoryItem>[
  CategoryItem(label: 'Veículos', icon: Icons.directions_car_outlined, color: AppColors.misc),
  CategoryItem(label: 'Imóveis', icon: Icons.home_outlined, color: AppColors.price),
  CategoryItem(label: 'Eletrônicos', icon: Icons.devices_outlined, color: AppColors.electronics),
  CategoryItem(label: 'Casa e Jardim', icon: Icons.chair_alt_outlined, color: AppColors.furniture),
  CategoryItem(label: 'Empregos', icon: Icons.work_outline, color: AppColors.primary),
  CategoryItem(label: 'Serviços', icon: Icons.handyman_outlined, color: AppColors.kitchen),
  CategoryItem(label: 'Moda e Acessórios', icon: Icons.checkroom_outlined, color: AppColors.clothing),
  CategoryItem(label: 'Esportes e Lazer', icon: Icons.sports_soccer_outlined, color: AppColors.distance),
  CategoryItem(label: 'Bebês e Crianças', icon: Icons.child_friendly_outlined, color: AppColors.accent),
  CategoryItem(label: 'Animais', icon: Icons.pets_outlined, color: AppColors.misc),
  CategoryItem(label: 'Negócios e Equipamentos', icon: Icons.store_outlined, color: AppColors.primary),
  CategoryItem(label: 'Agricultura e Rural', icon: Icons.agriculture_outlined, color: AppColors.kitchen),
  CategoryItem(label: 'Bilhetes e Eventos', icon: Icons.confirmation_number_outlined, color: AppColors.price),
  CategoryItem(label: 'Colecionáveis e Hobby', icon: Icons.collections_outlined, color: AppColors.electronics),
  CategoryItem(label: 'Sustentável / Segunda Vida', icon: Icons.recycling_outlined, color: AppColors.furniture),
];
