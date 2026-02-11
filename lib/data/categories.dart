import 'package:flutter/material.dart';

class CategoryItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> subcategories;

  const CategoryItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.subcategories = const [],
  });
}

const coreCategories = <CategoryItem>[
  CategoryItem(label: 'Imóveis', subtitle: 'Venda e aluguel', icon: Icons.home_work_outlined, color: Color(0xFF4F8DFF), subcategories: ['Venda de casas e apartamentos', 'Aluguel residencial', 'Terrenos e lotes', 'Imóveis comerciais', 'Temporada / férias']),
  CategoryItem(label: 'Veículos', subtitle: 'Carros e motos', icon: Icons.directions_car_filled_outlined, color: Color(0xFF7C5CFF), subcategories: ['Carros', 'Motos', 'Caminhões', 'Náutica (barcos, jetski)', 'Peças e acessórios']),
  CategoryItem(label: 'Eletrônicos e Tecnologia', subtitle: 'Tech e games', icon: Icons.devices_outlined, color: Color(0xFF00A5D8), subcategories: ['Celulares e tablets', 'Computadores e notebooks', 'TVs e áudio', 'Games e consoles', 'Câmeras']),
  CategoryItem(label: 'Casa e Jardim', subtitle: 'Móveis e decor', icon: Icons.weekend_outlined, color: Color(0xFF28B67E), subcategories: ['Móveis', 'Eletrodomésticos', 'Decoração', 'Ferramentas', 'Jardim e bricolagem']),
  CategoryItem(label: 'Moda e Beleza', subtitle: 'Roupas e estilo', icon: Icons.checkroom_outlined, color: Color(0xFFE47AA7), subcategories: ['Roupas masculinas/femininas/infantis', 'Calçados', 'Bolsas e acessórios', 'Joias e relógios', 'Beleza e cuidados pessoais']),
  CategoryItem(label: 'Serviços', subtitle: 'Fretes e reformas', icon: Icons.handyman_outlined, color: Color(0xFFFF9E57), subcategories: ['Reformas e construção', 'Mudanças e fretes', 'Informática', 'Aulas particulares', 'Eventos']),
  CategoryItem(label: 'Empregos', subtitle: 'Vagas e freela', icon: Icons.work_outline, color: Color(0xFF4D6BFF), subcategories: ['Vagas', 'Freelancers', 'Estágios', 'Serviços profissionais']),
  CategoryItem(label: 'Locação', subtitle: 'Alugue por dia', icon: Icons.key_outlined, color: Color(0xFF17A2A4), subcategories: ['Aluguel residencial', 'Temporada / férias', 'Ferramentas', 'Instrumentos musicais']),
];

const allCategories = <CategoryItem>[
  CategoryItem(label: 'Imóveis', subtitle: 'Venda, aluguel e temporada', icon: Icons.home_work_outlined, color: Color(0xFF4F8DFF), subcategories: ['Venda de casas e apartamentos', 'Aluguel residencial', 'Terrenos e lotes', 'Imóveis comerciais', 'Temporada / férias']),
  CategoryItem(label: 'Veículos', subtitle: 'Carros, motos e peças', icon: Icons.directions_car_filled_outlined, color: Color(0xFF7C5CFF), subcategories: ['Carros', 'Motos', 'Caminhões', 'Náutica (barcos, jetski)', 'Peças e acessórios']),
  CategoryItem(label: 'Eletrônicos e Tecnologia', subtitle: 'Celulares, PCs, TVs e games', icon: Icons.devices_other_outlined, color: Color(0xFF00A5D8), subcategories: ['Celulares e tablets', 'Computadores e notebooks', 'TVs e áudio', 'Games e consoles', 'Câmeras']),
  CategoryItem(label: 'Casa e Jardim', subtitle: 'Móveis, eletros e decoração', icon: Icons.chair_alt_outlined, color: Color(0xFF28B67E), subcategories: ['Móveis', 'Eletrodomésticos', 'Decoração', 'Ferramentas', 'Jardim e bricolagem']),
  CategoryItem(label: 'Moda e Beleza', subtitle: 'Roupas, calçados e acessórios', icon: Icons.checkroom_outlined, color: Color(0xFFE47AA7), subcategories: ['Roupas masculinas/femininas/infantis', 'Calçados', 'Bolsas e acessórios', 'Joias e relógios', 'Beleza e cuidados pessoais']),
  CategoryItem(label: 'Infantil', subtitle: 'Brinquedos e artigos infantis', icon: Icons.child_care_outlined, color: Color(0xFFFFB347), subcategories: ['Brinquedos', 'Carrinhos de bebê', 'Roupas infantis', 'Móveis infantis', 'Artigos escolares']),
  CategoryItem(label: 'Animais', subtitle: 'Pets, rações e acessórios', icon: Icons.pets_outlined, color: Color(0xFF8A6E5A), subcategories: ['Adoção / venda de pets', 'Acessórios', 'Rações', 'Serviços veterinários']),
  CategoryItem(label: 'Esportes e Lazer', subtitle: 'Bike, academia e hobbies', icon: Icons.sports_basketball_outlined, color: Color(0xFF23A0A2), subcategories: ['Bicicletas', 'Equipamentos de academia', 'Camping', 'Instrumentos musicais', 'Hobbies']),
  CategoryItem(label: 'Serviços', subtitle: 'Reformas, fretes e aulas', icon: Icons.handyman_outlined, color: Color(0xFFFF9E57), subcategories: ['Reformas e construção', 'Mudanças e fretes', 'Informática', 'Aulas particulares', 'Eventos']),
  CategoryItem(label: 'Empregos', subtitle: 'Vagas, freelancers e estágios', icon: Icons.work_outline, color: Color(0xFF4D6BFF), subcategories: ['Vagas', 'Freelancers', 'Estágios', 'Serviços profissionais']),
  CategoryItem(label: 'Indústria e Negócios', subtitle: 'Máquinas e equipamentos', icon: Icons.factory_outlined, color: Color(0xFF7384A8), subcategories: ['Máquinas industriais', 'Equipamentos comerciais', 'Materiais de construção', 'Estoques e lotes']),
  CategoryItem(label: 'Outros', subtitle: 'Ingressos, trocas e doações', icon: Icons.category_outlined, color: Color(0xFF5F6B7A), subcategories: ['Ingressos', 'Colecionáveis', 'Antiguidades', 'Doações', 'Trocas']),
  CategoryItem(label: 'Freelancers', subtitle: 'Serviços sob demanda', icon: Icons.design_services_outlined, color: Color(0xFF8F63E8), subcategories: ['Design', 'Programação', 'Marketing', 'Atendimento remoto']),
  CategoryItem(label: 'Locação', subtitle: 'Renting de itens e espaços', icon: Icons.key_outlined, color: Color(0xFF17A2A4), subcategories: ['Imóveis por temporada', 'Ferramentas', 'Equipamentos para eventos', 'Veículos por diária']),
];
