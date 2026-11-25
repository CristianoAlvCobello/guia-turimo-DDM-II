import 'dart:typed_data';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class LugaresServices {
  String endpoint = "https://guia.liliaborges.com.br/lugares";
  final int limite = 100;

  Future<List<LugaresModel>> buscarLugares() async {
    final lugares = <LugaresModel>[];

    for (int pagina = 1; pagina <= 10; pagina++) {
      final resposta = await http.get(
        Uri.parse('$endpoint?pagina=$pagina&limite=$limite'),
      ).timeout(const Duration(seconds: 15));
      if (resposta.statusCode != 200) {
        throw Exception('Não foi possível buscar os lugares.');
      }

      final corpo = jsonDecode(resposta.body);
      final List dados = corpo is List ? corpo : corpo['data'];
      lugares.addAll(dados.map((item) => LugaresModel.fromJson(item)));
      if (dados.length < limite) break;
    }
    return lugares;
  }

  Future<List<String>> buscarFotos(int id) async {
    for (final url in ['$endpoint/$id/galeria', '$endpoint/$id']) {
      try {
        final resposta = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
        if (resposta.statusCode != 200) continue;
        final fotos = LugaresModel.extrairFotos(jsonDecode(resposta.body));
        if (fotos.isNotEmpty) return fotos;
      } catch (_) {}
    }
    return [];
  }

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

  Future<void> enviarFoto(
    int id,
    Uint8List foto,
    String nomeFoto,
    String token,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse('$endpoint/$id/galeria'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        foto,
        filename: nomeFoto,
        contentType: _tipoImagem(nomeFoto),
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
