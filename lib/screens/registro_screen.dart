import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formulario = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formulario.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final sucesso = await auth.cadastrarUsuario(
      _nome.text.trim(),
      _email.text.trim(),
      _senha.text,
    );
    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada! Agora faça login.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.erro)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formulario,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nome,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (texto) => (texto ?? '').trim().isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (texto) => (texto ?? '').contains('@') ? null : 'E-mail inválido',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _senha,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    validator: (texto) => (texto ?? '').length >= 6 ? null : 'Mínimo de 6 caracteres',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmacao,
                    decoration: const InputDecoration(labelText: 'Confirmar senha'),
                    obscureText: true,
                    validator: (texto) => texto == _senha.text ? null : 'As senhas são diferentes',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.carregando ? null : _cadastrar,
                      child: Text(auth.carregando ? 'Salvando...' : 'Cadastrar'),
                    ),
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
