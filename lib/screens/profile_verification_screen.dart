import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/input_rules.dart';
import '../state/profile_state.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class ProfileVerificationScreen extends StatefulWidget {
  const ProfileVerificationScreen({super.key});

  @override
  State<ProfileVerificationScreen> createState() =>
      _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState extends State<ProfileVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _docController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  XFile? _documentPhoto;
  XFile? _selfiePhoto;

  @override
  void initState() {
    super.initState();
    _nameController.text = ProfileState.name.value;
    _emailController.text = ProfileState.email.value;
    _phoneController.text = ProfileState.phone.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _docController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar perfil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                'Verificação obrigatória',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Para publicar vendas e eventos, complete seus dados.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _Field(
                controller: _nameController,
                label: 'Nome completo',
                validator: AppInputRules.name,
                inputFormatters: AppInputRules.nameFormatters(),
                maxLength: 60,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: AppInputRules.email,
                inputFormatters: AppInputRules.emailFormatters(),
                maxLength: 80,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _phoneController,
                label: 'Telefone',
                keyboardType: TextInputType.phone,
                validator: (value) => AppInputRules.phone(value),
                inputFormatters: AppInputRules.phoneFormatters(),
                maxLength: 17,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _docController,
                label: 'Documento (DNI/NIE)',
                validator: AppInputRules.document,
                inputFormatters: AppInputRules.documentFormatters(),
                maxLength: 14,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              _Field(
                controller: _neighborhoodController,
                label: 'Bairro',
                validator: (value) => AppInputRules.required(value, 'Bairro'),
                inputFormatters: AppInputRules.shortTextFormatters(
                  maxLength: 60,
                ),
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              _UploadTile(
                label: 'Foto do documento',
                fileName: _documentPhoto?.name,
                actionLabel: 'Selecionar',
                onTap: _pickDocumentPhoto,
              ),
              const SizedBox(height: 12),
              _UploadTile(
                label: 'Selfie para verificação',
                fileName: _selfiePhoto?.name,
                actionLabel: 'Capturar',
                onTap: _pickSelfiePhoto,
              ),
              const SizedBox(height: 20),
              GradientButton(label: 'Concluir verificação', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_documentPhoto == null || _selfiePhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Envie a foto do documento e a selfie para concluir.'),
        ),
      );
      return;
    }
    ProfileState.updateBasicData(
      updatedName: _nameController.text,
      updatedEmail: _emailController.text,
      updatedPhone: _phoneController.text,
    );
    ProfileState.isVerified.value = true;
    Navigator.pop(context);
  }

  Future<void> _pickDocumentPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _documentPhoto = picked);
  }

  Future<void> _pickSelfiePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _selfiePhoto = picked);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
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
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      validator: validator ?? (value) => AppInputRules.required(value, 'Campo'),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final String? fileName;
  final String actionLabel;
  final VoidCallback onTap;

  const _UploadTile({
    required this.label,
    required this.fileName,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(
            fileName == null
                ? Icons.upload_file_outlined
                : Icons.check_circle_outline_rounded,
            color: fileName == null
                ? AppColors.primary
                : const Color(0xFF22C55E),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                if (fileName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    fileName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
