import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../controller/auth_controller.dart';
import '../controller/favoritos_controller.dart';
import '../controller/lugares_controller.dart';
import '../models/lugares_model.dart';
import '../services/session_service.dart';
import 'mapa_screen.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  int _aba = 0;
  LugaresModel? _lugarSelecionado;
  bool _soFavoritos = false;
  String _nomeUsuario = '';
  String _emailUsuario = '';
  String _fotoUsuario = '';

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritosController>().carregar();
    });
  }

  void _abrirNoMapa(LugaresModel lugar) {
    setState(() {
      _lugarSelecionado = lugar;
      _aba = 1;
    });
  }

  Future<void> _carregarUsuario() async {
    final sessao = SessionService();
    final nome = await sessao.pegarNome();
    final email = await sessao.pegarEmail();
    final foto = await sessao.pegarFoto();
    if (!mounted) return;
    setState(() {
      _nomeUsuario = nome;
      _emailUsuario = email;
      _fotoUsuario = foto;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controle = context.watch<LugaresController>();
    final favoritos = context.watch<FavoritosController>();
    final lugares = _soFavoritos
        ? controle.lugares.where((lugar) => favoritos.ehFavorito(lugar.id)).toList()
        : controle.lugares;

    return Scaffold(
      appBar: AppBar(
        title: Text(_aba == 0 ? 'Turistero' : 'Mapa'),
        actions: [
          IconButton(
            tooltip: 'Favoritos',
            onPressed: () => setState(() => _soFavoritos = !_soFavoritos),
            icon: Icon(_soFavoritos ? Icons.favorite : Icons.favorite_border),
          ),
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
                  ? _listaDeLugares(controle, lugares, favoritos)
                  : MapaScreen(
                      key: ValueKey(_lugarSelecionado?.id ?? 0),
                      lugares: lugares,
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

  Widget _listaDeLugares(
    LugaresController controle,
    List<LugaresModel> lugares,
    FavoritosController favoritos,
  ) {
    return RefreshIndicator(
      onRefresh: controle.listaLugares,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: lugares.length + 1,
        itemBuilder: (context, indice) {
          if (indice == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_emailUsuario.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: _fotoUsuario.isNotEmpty ? NetworkImage(_fotoUsuario) : null,
                        child: _fotoUsuario.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(_nomeUsuario.isNotEmpty ? _nomeUsuario : _emailUsuario),
                      subtitle: _nomeUsuario.isNotEmpty ? Text(_emailUsuario) : null,
                    ),
                  Text(
                    lugares.isEmpty
                        ? (_soFavoritos ? 'Nenhum lugar favorito' : 'Nenhum lugar cadastrado')
                        : '${lugares.length} lugares encontrados. Toque para ver o mapa',
                  ),
                ],
              ),
            );
          }

          final lugar = lugares[indice - 1];
          return Column(
            children: [ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(lugar.nome),
              subtitle: Text(lugar.categoria ?? 'Sem categoria'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Favoritar',
                    onPressed: () => favoritos.alternar(lugar.id),
                    icon: Icon(
                      favoritos.ehFavorito(lugar.id) ? Icons.favorite : Icons.favorite_border,
                      color: favoritos.ehFavorito(lugar.id) ? Colors.red : null,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _abrirNoMapa(lugar),
            ), const Divider(height: 1)],
          );
        },
      ),
    );
  }
}
