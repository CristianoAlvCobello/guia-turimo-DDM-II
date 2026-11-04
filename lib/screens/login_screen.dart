import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final sucesso = await auth.autenticarUsuario(_email.text.trim(), _senha.text);
    if (!mounted) return;

    if (sucesso) {
      Navigator.pushReplacementNamed(context, 'lugares');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.erro)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formulario,
              child: Column(
                children: [
                  const Text('Turistero', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    'Tu-ris-te-ro, Alguém que usa app dart, com flutter e APIs. Um mestre do desenvolvimento turistico de são roque',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (texto) => (texto ?? '').contains('@') ? null : 'Informe um e-mail válido',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _senha,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    validator: (texto) => (texto ?? '').isEmpty ? 'Informe a senha' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.carregando ? null : _entrar,
                      child: Text(auth.carregando ? 'Entrando...' : 'Entrar'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, 'registro'),
                    child: const Text('Criar uma conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
