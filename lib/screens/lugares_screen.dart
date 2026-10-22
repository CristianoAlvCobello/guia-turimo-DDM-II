import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore lugares"),
        actions: [
          Consumer<ThemeController>(
            builder: (context, controllerThema, child) => IconButton(
              onPressed: () => controllerThema.alternarTema(),
              icon: Icon(controllerThema.iconeAtual),
            ),
          ),
          IconButton(
            onPressed: () async {
              await context.read<AuthController>().deslogarUsuario();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, 'login');
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, 'cadastro'),
        tooltip: "Adicionar lugar",
        child: const Icon(Icons.add_location_alt_outlined),
      ),
      body: Consumer<LugaresController>(builder: (context, lugaresController, child) {
        if (lugaresController.carregando) {
          return Center(child: CircularProgressIndicator());
        }
        if (lugaresController.erro != '') {
          return Center(child: Text(lugaresController.erro));
        }
        if (lugaresController.lugares.isEmpty) {
          return Center(child: Text("Ainda não há lugares cadastrados."));
        }
        return RefreshIndicator(
          onRefresh: () => lugaresController.listaLugares(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
            itemCount: lugaresController.lugares.length,
            itemBuilder: (context, index) {
              final lugar = lugaresController.lugares[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(lugar.nome),
                  subtitle: Text(lugar.categoria.toString()),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.place_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
