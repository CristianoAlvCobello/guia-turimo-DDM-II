import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/auth_controller.dart';
import 'controller/categorias_controller.dart';
import 'controller/lugares_controller.dart';
import 'screens/cadastro_lugar.dart';
import 'screens/login_screen.dart';
import 'screens/lugares_screen.dart';
import 'screens/registro_screen.dart';

void main() {
  runApp(const Turistero());
}

class Turistero extends StatelessWidget {
  const Turistero({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LugaresController()),
        ChangeNotifierProvider(create: (_) => CategoriasController()),
      ],
      child: MaterialApp(
        title: 'Turistero',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false,
        ),
        initialRoute: 'login',
        routes: {
          'login': (_) => const LoginScreen(),
          'registro': (_) => const RegistroScreen(),
          'lugares': (_) => const LugaresScreen(),
          'cadastro': (_) => const CadastroLugar(),
        },
      ),
    );
  }
}
