import 'dart:convert';
import 'package:http/http.dart' as http;

class LocalEncontrado {
  final double latitude;
  final double longitude;
  final String endereco;

  LocalEncontrado(this.latitude, this.longitude, this.endereco);
}

class LocalizacaoService {
  static String formatarCepParcial(String texto) {
    if (!RegExp(r'^[0-9-]*$').hasMatch(texto)) return texto;

    final numeros = texto.replaceAll('-', '');

    if (numeros.length <= 5 || numeros.length > 8) {
      return numeros;
    }

    return '${numeros.substring(0, 5)}-${numeros.substring(5)}';
  }

  static String prepararBusca(String texto) {
    final valor = texto.trim();

    if (valor.isEmpty) {
      throw Exception('Digite um endereço ou CEP.');
    }

    if (RegExp(r'^[0-9.\s-]+$').hasMatch(valor)) {
      final numeros = valor.replaceAll(RegExp(r'\D'), '');

      if (numeros.length != 8) {
        throw Exception('CEP inválido.');
      }

      return '${numeros.substring(0, 5)}-${numeros.substring(5)}';
    }

    return valor;
  }

  Future<LocalEncontrado?> buscar(String texto) async {
    String endereco = prepararBusca(texto);

    if (RegExp(r'^\d{5}-\d{3}$').hasMatch(endereco)) {
      final cep = endereco.replaceAll('-', '');

      final resposta = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

      if (resposta.statusCode != 200) {
        throw Exception('Erro ao consultar CEP.');
      }

      final dados = jsonDecode(resposta.body);

      if (dados['erro'] == true) {
        throw Exception('CEP não encontrado.');
      }

      endereco = [
        dados['logradouro'],
        dados['bairro'],
        dados['localidade'],
        dados['uf'],
        'Brasil',
      ].where((parte) => parte != null && parte.toString().isNotEmpty)
       .join(', ');
    }

    final url = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': endereco,
        'format': 'json',
        'limit': '1',
      },
    );

    final resposta = await http.get(url);

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar localização.');
    }

    final List dados = jsonDecode(resposta.body);

    if (dados.isEmpty) {
      return null;
    }

    final local = dados.first;

    return LocalEncontrado(
      double.parse(local['lat'].toString()),
      double.parse(local['lon'].toString()),
      local['display_name'].toString(),
    );
  }
}
