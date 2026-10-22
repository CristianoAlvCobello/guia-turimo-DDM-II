import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String urlLogin = 'https://guia.liliaborges.com.br/login';
  final String urlUsuarios = 'https://guia.liliaborges.com.br/usuarios';

  Future<Map> autenticar(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(urlLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "senha": senha}),
      );
      final dados = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // a API pode devolver {data: {...}} ou os dados direto
        if (dados is Map && dados['data'] is Map) return dados['data'];
        return dados;
      } else {
        debugPrint(dados.toString());
        return {};
      }
    } catch (e) {
      rethrow;
    }
  }

  // Cadastro de usuário: devolve a mensagem da API ou lança Exception
  Future<String> cadastrar(String nome, String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(urlUsuarios),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"nome": nome, "email": email, "senha": senha}),
      );
      final dados = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return dados['message'] ?? 'Usuário cadastrado com sucesso!';
      } else {
        throw Exception(
          dados['message'] ?? dados['erro'] ?? dados['error'] ??
              'Erro ao cadastrar usuário (${response.statusCode})',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
