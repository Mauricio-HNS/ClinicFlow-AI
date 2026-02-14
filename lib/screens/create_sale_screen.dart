import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../data/categories.dart';
import '../state/notifications_state.dart';
import '../state/published_sales_state.dart';
import '../state/reputation_state.dart';
import '../state/search_alert_state.dart';
import '../state/event_rewards_state.dart';
import '../theme/app_colors.dart';
import '../utils/input_rules.dart';
import '../widgets/common.dart';
import '../state/profile_state.dart';
import '../models/sale.dart';

class CreateSaleScreen extends StatefulWidget {
  final bool isEvent;
  final bool consumeEventCreditOnPublish;
  final String? paidEventPaymentId;
  final String? initialCategory;

  const CreateSaleScreen({
    super.key,
    this.isEvent = false,
    this.consumeEventCreditOnPublish = false,
    this.paidEventPaymentId,
    this.initialCategory,
  });

  @override
  State<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends State<CreateSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _featured = false;
  late String _category = widget.initialCategory ?? allCategories.first.label;
  final List<XFile> _photos = [];
  final ImagePicker _picker = ImagePicker();
  static const int _maxPhotos = 12;
  late final List<String> _categoryOptions = allCategories
      .map((item) => item.label)
      .toList(growable: false);

  static const Set<String> _photoRequiredCategories = {
    'Imóveis',
    'Veículos',
    'Eletrônicos e Tecnologia',
    'Casa e Jardim',
    'Moda e Beleza',
    'Esportes e Lazer',
    'Infantil',
    'Animais',
    'Indústria e Negócios',
    'Locação',
    'Outros',
  };

  static const Set<String> _photoOptionalCategories = {
    'Empregos',
    'Serviços',
    'Freelancers',
  };

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
    final nounLabel = widget.isEvent ? 'Evento' : 'Venda';
    final titleFieldLabel = widget.isEvent
        ? 'Título do evento'
        : 'Título da venda';
    final priceFieldLabel = widget.isEvent
        ? 'Preço do ingresso ou faixa'
        : 'Preço ou faixa';
    final priceFieldHint = widget.isEvent ? '€5–€30' : '€10–€60';
    final descriptionHint = widget.isEvent
        ? 'Ex: feira local com música, alimentação e atividades.'
        : 'Itens em ótimo estado, retirada rápida.';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEvent ? 'Criar evento' : 'Vender item'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                widget.isEvent ? 'Criar evento' : 'Criar venda',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Cadastro rápido em 4 passos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: ProfileState.isVerified,
                builder: (context, verified, _) {
                  if (verified) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Complete seu perfil para publicar.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/profile-verification',
                          ),
                          child: const Text('Completar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Stepper(
                currentStep: _currentStep,
                onStepContinue: _handleContinue,
                onStepCancel: _handleBack,
                onStepTapped: (value) => setState(() => _currentStep = value),
                controlsBuilder: (context, details) {
                  final actionLabel = _currentStep == 3 ? 'Publicar' : 'Continuar';
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 46,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDFEFF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.8,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFFFFFFF),
                                  offset: Offset(-3, -3),
                                  blurRadius: 8,
                                ),
                                BoxShadow(
                                  color: Color(0x260F2D57),
                                  offset: Offset(5, 5),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: details.onStepContinue,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      actionLabel,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Voltar'),
                          ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: const Text('Cadastro rápido'),
                    isActive: _currentStep >= 0,
                    content: Column(
                      children: [
                        _TextField(
                          controller: _nameController,
                          label: 'Nome',
                          hint: 'Seu nome completo',
                          validator: AppInputRules.name,
                          inputFormatters: AppInputRules.nameFormatters(),
                          maxLength: 60,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'email@exemplo.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: AppInputRules.email,
                          inputFormatters: AppInputRules.emailFormatters(),
                          maxLength: 80,
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _phoneController,
                          label: 'Telefone',
                          hint: '+34 600 000 000',
                          keyboardType: TextInputType.phone,
                          validator: (value) => AppInputRules.phone(value),
                          inputFormatters: AppInputRules.phoneFormatters(),
                          maxLength: 17,
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: const Text('Local + data'),
                    isActive: _currentStep >= 1,
                    content: Column(
                      children: [
                        _TextField(
                          controller: _addressController,
                          label: 'Endereço aproximado',
                          hint: 'Barrio / rua aproximada',
                          validator: (value) =>
                              AppInputRules.required(value, 'Endereço'),
                          inputFormatters: AppInputRules.shortTextFormatters(
                            maxLength: 80,
                          ),
                          maxLength: 80,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _TextField(
                                controller: _dateController,
                                label: 'Data',
                                hint: '12/02/2026',
                                validator: _validateDate,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9/]'),
                                  ),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                maxLength: 10,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TextField(
                                controller: _timeController,
                                label: 'Hora',
                                hint: '15:00',
                                validator: _validateTime,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9:]'),
                                  ),
                                  LengthLimitingTextInputFormatter(5),
                                ],
                                maxLength: 5,
                              ),
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
                        _TextField(
                          controller: _titleController,
                          label: titleFieldLabel,
                          hint: 'Ex: Sala completa + decoração',
                          validator: (value) =>
                              AppInputRules.required(value, 'Título'),
                          inputFormatters: AppInputRules.shortTextFormatters(
                            maxLength: 80,
                          ),
                          maxLength: 80,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                          ),
                          items: _categoryOptions
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) => setState(
                            () => _category = value ?? _categoryOptions.first,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _priceController,
                          label: priceFieldLabel,
                          hint: priceFieldHint,
                          validator: _validatePrice,
                          inputFormatters: AppInputRules.priceFormatters(),
                          maxLength: 24,
                        ),
                        const SizedBox(height: 12),
                        _TextField(
                          controller: _descriptionController,
                          label: 'Descrição curta',
                          hint: descriptionHint,
                          maxLines: 3,
                          validator: (value) =>
                              AppInputRules.required(value, 'Descrição'),
                          inputFormatters: AppInputRules.longTextFormatters(
                            maxLength: 320,
                          ),
                          maxLength: 320,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fotos (${_photos.length}/$_maxPhotos)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _requiresPhoto()
                              ? 'Mínimo obrigatório: 1 foto real.'
                              : 'Foto opcional para esta categoria, mas aumenta a credibilidade.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _PhotoTile(
                              label: 'Adicionar',
                              onTap: _photos.length >= _maxPhotos
                                  ? null
                                  : _pickPhoto,
                            ),
                            ..._photos.map(
                              (photo) => _PhotoTile(file: File(photo.path)),
                            ),
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
                                activeThumbColor: AppColors.primary,
                                onChanged: (value) =>
                                    setState(() => _featured = value),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$nounLabel destacado',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Aparece no topo do mapa e nas notificações.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
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
                              Text(
                                'Pagamento rápido',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
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
                                      icon: const Icon(
                                        Icons.account_balance_wallet_outlined,
                                      ),
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
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_currentStep == 3) {
      final verified = ProfileState.isVerified.value;
      if (!verified) {
        _showVerificationRequired();
        return;
      }
      if (_requiresPhoto() && _photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Anúncios com foto recebem até 5x mais contatos. Adicione pelo menos uma foto para publicar.',
            ),
          ),
        );
        return;
      }
      final valid = _formKey.currentState?.validate() ?? false;
      if (valid) {
        await _publishSale();
        if (!mounted) return;
        if (!widget.isEvent) {
          ReputationState.addPublishedSalePoints();
        }
        _triggerSearchAlertNotifications();
        if (_photos.length == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Dica: anúncios com 3 ou mais fotos vendem mais rápido.',
              ),
            ),
          );
        } else if (_photos.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ótimo! Seu anúncio tem boas chances de venda.'),
            ),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEvent
                  ? 'Evento publicado com sucesso.'
                  : 'Venda publicada com sucesso.',
            ),
          ),
        );
        Navigator.pushNamed(context, '/my-sales');
      }
      return;
    }
    setState(() => _currentStep += 1);
  }

  void _handleBack() {
    if (_currentStep == 0) return;
    setState(() => _currentStep -= 1);
  }

  void _showVerificationRequired() {
    final publicationLabel = widget.isEvent ? 'eventos' : 'vendas';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verificação necessária'),
          content: Text(
            'Para publicar $publicationLabel, complete seu perfil com dados reais.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Agora não'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile-verification');
              },
              child: const Text('Completar'),
            ),
          ],
        );
      },
    );
  }

  bool _requiresPhoto() {
    if (_photoOptionalCategories.contains(_category)) return false;
    if (_photoRequiredCategories.contains(_category)) return true;
    return true;
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= _maxPhotos) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _photos.add(picked));
  }

  void _triggerSearchAlertNotifications() {
    final sourceText =
        '${_titleController.text} ${_descriptionController.text} $_category';
    final matched = SearchAlertState.matchTerm(sourceText);
    if (matched == null) return;
    final listingTitle = _titleController.text.trim().isEmpty
        ? 'Novo anúncio'
        : _titleController.text.trim();
    NotificationsState.addSearchMatch(
      term: matched,
      listingTitle: listingTitle,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alerta enviado para buscas: "$matched"')),
    );
  }

  String? _validateDate(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Data obrigatória';
    final parts = raw.split('/');
    if (parts.length != 3) return 'Use o formato DD/MM/AAAA';
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida';
    }
    if (day < 1 || day > 31 || month < 1 || month > 12 || year < 2024) {
      return 'Data inválida';
    }
    return null;
  }

  String? _validateTime(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Hora obrigatória';
    final parts = raw.split(':');
    if (parts.length != 2) return 'Use o formato HH:MM';
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return 'Hora inválida';
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return 'Hora inválida';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Preço obrigatório';
    final hasDigit = RegExp(r'\d').hasMatch(raw);
    if (!hasDigit) return 'Preço inválido';
    return null;
  }

  Future<void> _publishSale() async {
    final title = _titleController.text.trim();
    final price = _priceController.text.trim();
    final date = _dateController.text.trim();
    final time = _timeController.text.trim();
    final selectedCategory = allCategories.firstWhere(
      (item) => item.label == _category,
      orElse: () => allCategories.first,
    );
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final formattedDate =
        (date.isEmpty ? 'Hoje' : date) + (time.isEmpty ? '' : ', $time');

    final publishedSale = Sale(
      id: id,
      title: title.isEmpty ? 'Novo anúncio' : title,
      category: _category,
      price: price.isEmpty ? 'A combinar' : price,
      distance: 'Seu anúncio',
      date: formattedDate,
      imageAsset: categoryCoverAssets[_category],
      imageUrl: categoryCoverUrls[_category],
      color: selectedCategory.color,
      icon: selectedCategory.icon,
      lat: 40.4168,
      lng: -3.7038,
      featured: _featured,
      isEvent: widget.isEvent,
      consumeEventCredit: widget.consumeEventCreditOnPublish,
      eventPaymentId: widget.paidEventPaymentId,
      photoPaths: _photos.map((photo) => photo.path).toList(growable: false),
    );

    await PublishedSalesState.createSmart(publishedSale);
    if (widget.consumeEventCreditOnPublish) {
      EventRewardsState.consumeFreeCredit();
    }
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      validator: validator ?? (value) => AppInputRules.required(value, 'Campo'),
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
  final VoidCallback? onTap;
  final File? file;

  const _PhotoTile({this.label = '', this.onTap, this.file});

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
      child: InkWell(
        onTap: onTap,
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(file!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 6),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
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
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
