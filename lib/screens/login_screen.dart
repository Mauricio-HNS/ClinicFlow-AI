import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                Text('Entrar', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 12),
                Text(
                  'Acesse suas vendas e alertas.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Email obrigatório'
                      : null,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'email@exemplo.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Senha mínima 6 caracteres'
                      : null,
                  obscureText: _obscure,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Esqueci a senha'),
                  ),
                ),
                const SizedBox(height: 12),
                // TODO(mauricio): remover este atalho temporário antes de publicar em produção.
                OutlinedButton.icon(
                  onPressed: _quickAccess,
                  icon: const Icon(Icons.flash_on_outlined),
                  label: const Text('Entrar sem código'),
                ),
                const SizedBox(height: 12),
                GradientButton(label: 'Entrar', onPressed: _submit),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Criar conta',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/register'),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0,
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
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha válidos.')),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _quickAccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Acesso rápido temporário ativado.')),
    );
    Navigator.pushReplacementNamed(context, '/home');
  }
}
