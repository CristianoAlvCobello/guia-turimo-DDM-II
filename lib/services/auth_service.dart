
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String urlLogin = 'https://guia.liliaborges.com.br/login';
  final String urlUsuarios = 'https://guia.liliaborges.com.br/usuarios';

  final GoogleSignIn _google = GoogleSignIn.instance;

  Future<void>? _googleInitialization;

  Future<void> _inicializarGoogle() {
    return _googleInitialization ??= _google.initialize();
  }

  Future<Map> autenticar(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(urlLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "senha": senha}),
      );

      final dados = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (dados is Map && dados['data'] is Map) {
          return dados['data'];
        }
        return dados;
      } else {
        debugPrint(dados.toString());
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> cadastrar(
      String nome,
      String email,
      String senha,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(urlUsuarios),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": nome,
          "email": email,
          "senha": senha,
        }),
      );

      final dados = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return dados['message'] ?? 'Usuário cadastrado com sucesso!';
      } else {
        throw Exception(
          dados['message'] ??
              dados['erro'] ??
              dados['error'] ??
              'Erro ao cadastrar usuário (${response.statusCode})',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> entrarComGoogle() async {
    try {
      await _inicializarGoogle();

      if (!_google.supportsAuthenticate()) {
        throw UnsupportedError(
          'Autenticação Google por este método não é suportada nesta plataforma.',
        );
      }

      final conta = await _google.authenticate();
      final autenticacao = conta.authentication;

      final idToken = autenticacao.idToken;

      if (idToken == null) {
        throw Exception('Não foi possível obter o token do Google.');
      }

      final credencial = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final resultado = await FirebaseAuth.instance.signInWithCredential(
        credencial,
      );

      return resultado.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sairDoGoogle() async {
    try {
      await _inicializarGoogle();

      await FirebaseAuth.instance.signOut();
      await _google.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
