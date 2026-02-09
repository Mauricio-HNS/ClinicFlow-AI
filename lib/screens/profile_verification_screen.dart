import 'package:flutter/material.dart';
import '../state/profile_state.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class ProfileVerificationScreen extends StatefulWidget {
  const ProfileVerificationScreen({super.key});

  @override
  State<ProfileVerificationScreen> createState() => _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState extends State<ProfileVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _docController = TextEditingController();
  final _neighborhoodController = TextEditingController();

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
              Text('Verificação obrigatória', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Para publicar vendas e eventos, complete seus dados.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              _Field(controller: _nameController, label: 'Nome completo'),
              const SizedBox(height: 12),
              _Field(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _Field(controller: _phoneController, label: 'Telefone', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _Field(controller: _docController, label: 'Documento (DNI/NIE)'),
              const SizedBox(height: 12),
              _Field(controller: _neighborhoodController, label: 'Bairro'),
              const SizedBox(height: 12),
              _UploadTile(label: 'Foto do documento'),
              const SizedBox(height: 12),
              _UploadTile(label: 'Selfie para verificação'),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Concluir verificação',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    ProfileState.isVerified.value = true;
    Navigator.pop(context);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const _Field({required this.controller, required this.label, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;

  const _UploadTile({required this.label});

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
          const Icon(Icons.upload_file_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          TextButton(onPressed: () {}, child: const Text('Enviar')),
        ],
      ),
    );
  }
}
