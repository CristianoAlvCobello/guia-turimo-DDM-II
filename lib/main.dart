import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'controller/auth_controller.dart';
import 'controller/categorias_controller.dart';
import 'controller/favoritos_controller.dart';
import 'controller/lugares_controller.dart';
import 'firebase_options.dart';
import 'screens/cadastro_lugar.dart';
import 'screens/login_screen.dart';
import 'screens/lugares_screen.dart';
import 'screens/registro_screen.dart';
import 'services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GoogleSignIn.instance.initialize();

  final logado = await SessionService().estaLogado();

  runApp(Turistero(logado: logado));
}

class Turistero extends StatelessWidget {
  final bool logado;

  const Turistero({super.key, this.logado = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LugaresController()),
        ChangeNotifierProvider(create: (_) => CategoriasController()),
        ChangeNotifierProvider(create: (_) => FavoritosController()),
      ],
      child: MaterialApp(
        title: 'Turistero',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false,
        ),
        initialRoute: logado ? 'lugares' : 'login',
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
