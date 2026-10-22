import 'dart:convert';
import 'package:guia_turismo/models/categoria_model.dart';
import 'package:http/http.dart' as http;

class CategoriasService {
  String endpoint = "https://guia.liliaborges.com.br/categorias";

  Future<List<CategoriaModel>> buscarCategorias() async {
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final dynamic corpo = jsonDecode(response.body);
        // a API pode devolver a lista direto ou dentro de "data"
        final List<dynamic> data = corpo is List ? corpo : corpo['data'];
        return data.map((item) => CategoriaModel.fromJson(item)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
