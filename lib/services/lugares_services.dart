import 'dart:io';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class LugaresServices {
  String endpoint = "https://guia.liliaborges.com.br/lugares";
  int pagina = 1;
  int limite = 10;

  Future<List<LugaresModel>> buscarLugares() async {
    try {
      final response = await http.get(
        Uri.parse('$endpoint?pagina=$pagina&limite=$limite'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((item) => LugaresModel.fromJson(item)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Devolve {'message': String, 'id': int?} (id pode vir nulo se a API não devolver)
  Future<Map<String, dynamic>> cadastrarLugar(
    LugaresModel dados,
    String token,
  ) async {
    try {
      if (token.isEmpty) {
        throw Exception("Não autorizado. Faça login novamente.");
      }
      final resposta = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(dados.toJson()),
      );
      final Map<String, dynamic> mensagem = jsonDecode(resposta.body);
      if (resposta.statusCode == 200 || resposta.statusCode == 201) {
        int? id;
        for (final chave in ['data', 'lugar']) {
          final item = mensagem[chave];
          if (item is Map && item['id'] != null) {
            id = int.tryParse(item['id'].toString());
          }
        }
        id ??= int.tryParse((mensagem['id'] ?? '').toString());
        return {
          'message': mensagem['message'] ?? 'Lugar cadastrado com sucesso!',
          'id': id,
        };
      }
      throw Exception(
        mensagem['message'] ?? mensagem['erro'] ?? mensagem['error'] ??
            'Erro ao cadastrar lugar (${resposta.statusCode})',
      );
    } catch (erro) {
      rethrow;
    }
  }

  // Plano B: se a API não devolver o id, procura o lugar recém-criado pelo nome
  Future<int?> buscarIdPorNome(String nome) async {
    try {
      final response = await http.get(Uri.parse('$endpoint?pagina=1&limite=100'));
      if (response.statusCode != 200) return null;
      final List<dynamic> data = jsonDecode(response.body)['data'];
      int? maior;
      for (final item in data) {
        if (item['nome'] == nome) {
          final id = int.tryParse(item['id'].toString());
          if (id != null && (maior == null || id > maior)) maior = id;
        }
      }
      return maior;
    } catch (e) {
      return null;
    }
  }

  // POST /lugares/{id}/galeria (multipart/form-data, campo "foto")
  Future<void> enviarFoto(int id, File foto, String token) async {
    final request = http.MultipartRequest('POST', Uri.parse('$endpoint/$id/galeria'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'foto',
        foto.path,
        contentType: _tipoImagem(foto.path),
      ),
    );
    final enviada = await request.send();
    final resposta = await http.Response.fromStream(enviada);
    if (resposta.statusCode == 200 || resposta.statusCode == 201) return;
    String motivo = 'erro ${resposta.statusCode}';
    try {
      final corpo = jsonDecode(resposta.body);
      motivo = corpo['message'] ?? corpo['erro'] ?? corpo['error'] ?? motivo;
    } catch (_) {}
    throw Exception(motivo);
  }

  MediaType _tipoImagem(String caminho) {
    final nome = caminho.toLowerCase();
    if (nome.endsWith('.png')) return MediaType('image', 'png');
    if (nome.endsWith('.webp')) return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }
}
