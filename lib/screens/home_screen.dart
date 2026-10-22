import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/theme_controller.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guia de Turismo"),
        actions: [
          Consumer<ThemeController>(
            builder: (context, controllerThema, child) => IconButton(
              onPressed: () => controllerThema.alternarTema(),
              icon: Icon(controllerThema.iconeAtual),
            ),
          ),
        ],
      ),
    );
  }
}
