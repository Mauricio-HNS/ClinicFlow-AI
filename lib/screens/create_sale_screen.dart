import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class CreateSaleScreen extends StatefulWidget {
  const CreateSaleScreen({super.key});

  @override
  State<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends State<CreateSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _featured = false;
  String _category = 'Móveis';

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Criar venda', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Cadastro rápido em 4 passos', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Stepper(
              currentStep: _currentStep,
              onStepContinue: _handleContinue,
              onStepCancel: _handleBack,
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    FilledButton(
                      onPressed: details.onStepContinue,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                      child: Text(_currentStep == 3 ? 'Publicar' : 'Continuar'),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Voltar'),
                      ),
                  ],
                );
              },
              steps: [
                Step(
                  title: const Text('Cadastro rápido'),
                  isActive: _currentStep >= 0,
                  content: Column(
                    children: [
                      _TextField(controller: _nameController, label: 'Nome', hint: 'Seu nome completo'),
                      const SizedBox(height: 12),
                      _TextField(controller: _emailController, label: 'Email', hint: 'email@exemplo.com', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _TextField(controller: _phoneController, label: 'Telefone', hint: '+34 600 000 000', keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Local + data'),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      _TextField(controller: _addressController, label: 'Endereço aproximado', hint: 'Barrio / rua aproximada'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _TextField(controller: _dateController, label: 'Data', hint: '12/02/2026'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TextField(controller: _timeController, label: 'Hora', hint: '15:00'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Itens e fotos'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TextField(controller: _titleController, label: 'Título da venda', hint: 'Ex: Sala completa + decoração'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(labelText: 'Categoria'),
                        items: const [
                          DropdownMenuItem(value: 'Móveis', child: Text('Móveis')),
                          DropdownMenuItem(value: 'Roupas', child: Text('Roupas')),
                          DropdownMenuItem(value: 'Eletrônicos', child: Text('Eletrônicos')),
                          DropdownMenuItem(value: 'Cozinha', child: Text('Cozinha')),
                          DropdownMenuItem(value: 'Misc', child: Text('Misc')),
                        ],
                        onChanged: (value) => setState(() => _category = value ?? 'Móveis'),
                      ),
                      const SizedBox(height: 12),
                      _TextField(controller: _priceController, label: 'Preço ou faixa', hint: '€10–€60'),
                      const SizedBox(height: 12),
                      _TextField(
                        controller: _descriptionController,
                        label: 'Descrição curta',
                        hint: 'Itens em ótimo estado, retirada rápida.',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Text('Fotos', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _PhotoTile(label: 'Adicionar'),
                          _PhotoTile(label: 'Foto 1'),
                          _PhotoTile(label: 'Foto 2'),
                        ],
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Destaque opcional'),
                  isActive: _currentStep >= 3,
                  content: Column(
                    children: [
                      SectionCard(
                        child: Row(
                          children: [
                            Switch(
                              value: _featured,
                              activeColor: AppColors.primary,
                              onChanged: (value) => setState(() => _featured = value),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Venda destacada', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Aparece no topo do mapa e nas notificações.', style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pagamento rápido', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _PriceChip(label: '€3'),
                                const SizedBox(width: 8),
                                _PriceChip(label: '€5'),
                                const SizedBox(width: 8),
                                _PriceChip(label: '€10'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.credit_card),
                                    label: const Text('Stripe'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.account_balance_wallet_outlined),
                                    label: const Text('PayPal'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_currentStep == 3) {
      final valid = _formKey.currentState?.validate() ?? false;
      if (valid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venda publicada com sucesso.')),
        );
      }
      return;
    }
    setState(() => _currentStep += 1);
  }

  void _handleBack() {
    if (_currentStep == 0) return;
    setState(() => _currentStep -= 1);
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;

  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String label;

  const _PhotoTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;

  const _PriceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}
