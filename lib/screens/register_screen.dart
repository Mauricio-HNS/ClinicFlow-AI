import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: 12),
                Text('Criar conta', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 12),
                Text('Crie sua conta para publicar vendas e acompanhar compras.', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  validator: (value) => (value == null || value.isEmpty) ? 'Nome obrigatório' : null,
                  decoration: InputDecoration(
                    labelText: 'Nome completo',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  validator: (value) => (value == null || value.isEmpty) ? 'Email obrigatório' : null,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'email@exemplo.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) => (value == null || value.isEmpty) ? 'Telefone obrigatório' : null,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    hintText: '+34 600 000 000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) => (value == null || value.length < 6) ? 'Senha mínima 6 caracteres' : null,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Criar conta',
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Já tenho conta',
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    Navigator.pushReplacementNamed(context, '/home');
  }
}
