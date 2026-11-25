import 'package:guia_turismo/services/auth_service.dart';
import 'package:guia_turismo/services/session_service.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  int idLogado = 0;
  bool carregando = false;
  String erro = '';

  Future<bool> autenticarUsuario(String email, String senha) async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      final Map dados = await AuthService().autenticar(email, senha);
      final String? token = dados['token'];
      if (token == null) {
        erro = 'Login ou senha inválidos!';
        return false;
      }
      await SessionService().salvarToken(token);
      if (dados['usuario'] is Map) {
        await SessionService().salvarUsuario(dados['usuario']);
      }
      return true;
    } catch (e) {
      erro = 'Erro: ${e.toString()}';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> autenticarComGoogle() async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      final usuario = await AuthService().entrarComGoogle();
      if (usuario == null) {
        erro = 'Login com Google cancelado.';
        return false;
      }
      await SessionService().salvarUsuario({
        'nome': usuario.displayName ?? '',
        'email': usuario.email ?? '',
        'foto': usuario.photoURL ?? '',
      });
      await SessionService().salvarLoginGoogle();
      return true;
    } catch (e) {
      erro = 'Erro: ${e.toString()}';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrarUsuario(String nome, String email, String senha) async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      await AuthService().cadastrar(nome, email, senha);
      return true;
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> deslogarUsuario() async {
    await AuthService().sairDoGoogle();
    await SessionService().logout();
  }
}
