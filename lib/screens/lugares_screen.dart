import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/auth_controller.dart';
import '../controller/lugares_controller.dart';
import '../models/lugares_model.dart';
import 'mapa_screen.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  int _aba = 0;
  LugaresModel? _lugarSelecionado;

  void _abrirNoMapa(LugaresModel lugar) {
    setState(() {
      _lugarSelecionado = lugar;
      _aba = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controle = context.watch<LugaresController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_aba == 0 ? 'Turistero' : 'Mapa'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: controle.carregando ? null : controle.listaLugares,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () async {
              await context.read<AuthController>().deslogarUsuario();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, 'login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: controle.carregando && controle.lugares.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : controle.erro.isNotEmpty && controle.lugares.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Não achou os lugares.'),
                      TextButton(
                        onPressed: controle.listaLugares,
                        child: const Text('Tente novamente'),
                      ),
                    ],
                  ),
                )
              : _aba == 0
                  ? _listaDeLugares(controle)
                  : MapaScreen(
                      key: ValueKey(_lugarSelecionado?.id ?? 0),
                      lugares: controle.lugares,
                      lugarSelecionado: _lugarSelecionado,
                    ),
      floatingActionButton: _aba == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, 'cadastro'),
              tooltip: 'Novo lugar',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aba,
        onTap: (indice) => setState(() {
          _aba = indice;
          _lugarSelecionado = null;
        }),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lugares'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
        ],
      ),
    );
  }

  Widget _listaDeLugares(LugaresController controle) {
    return RefreshIndicator(
      onRefresh: controle.listaLugares,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: controle.lugares.length + 1,
        itemBuilder: (context, indice) {
          if (indice == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                controle.lugares.isEmpty
                    ? 'Nenhum lugar cadastrado'
                    : '${controle.lugares.length} lugares encontrados. Toque para ver o mapa',
              ),
            );
          }

          final lugar = controle.lugares[indice - 1];
          return Column(
            children: [ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(lugar.nome),
              subtitle: Text(lugar.categoria ?? 'Sem categoria'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _abrirNoMapa(lugar),
            ), const Divider(height: 1)],
          );
        },
      ),
    );
  }
}
