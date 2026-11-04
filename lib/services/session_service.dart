import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static String nome = '';
  static String email = '';

  Future<String> pegarNome() async {
    final prefs = await SharedPreferences.getInstance();
    nome = prefs.getString('nome') ?? '';
    return nome;
  }

  Future<String> pegarEmail() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    return email;
  }

  Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> pegarToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> salvarUsuario(Map user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setString('nome', user['nome'] ?? '');
  }
}
