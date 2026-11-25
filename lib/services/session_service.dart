import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static String nome = '';
  static String email = '';
  static String foto = '';

  Future<String> pegarNome() async {
    final prefs = await SharedPreferences.getInstance();
    nome = prefs.getString('nome') ?? '';
    return nome;
  }

  Future<String> pegarFoto() async {
    final prefs = await SharedPreferences.getInstance();
    foto = prefs.getString('foto') ?? '';
    return foto;
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
    await prefs.remove('google');
    await prefs.remove('nome');
    await prefs.remove('email');
    await prefs.remove('foto');
    nome = '';
    email = '';
    foto = '';
  }

  Future<void> salvarLoginGoogle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('google', true);
  }

  Future<bool> estaLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return token.isNotEmpty || (prefs.getBool('google') ?? false);
  }

  Future<void> salvarUsuario(Map user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setString('nome', user['nome'] ?? '');
    await prefs.setString('foto', user['foto'] ?? '');
  }
}
