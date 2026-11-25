class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String? descricao;
  final int categoriaId;
  final List<String> fotos;

  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria = '',
    required this.latitude,
    required this.longitude,
    this.descricao = '',
    required this.categoriaId,
    this.fotos = const [],
  });

  factory LugaresModel.fromJson(Map json) {
    return LugaresModel(
      id: int.tryParse('${json['id']}') ?? 0,
      nome: '${json['nome'] ?? ''}',
      latitude: double.tryParse('${json['latitude']}') ?? 0,
      longitude: double.tryParse('${json['longitude']}') ?? 0,
      descricao: json['descricao']?.toString(),
      categoria: json['categoria'] is Map
          ? json['categoria']['nome']?.toString()
          : json['categoria']?.toString(),
      categoriaId: int.tryParse('${json['categoriaId'] ?? (json['categoria'] is Map ? json['categoria']['id'] : null)}') ?? 0,
      fotos: extrairFotos(json),
    );
  }

  static const String _urlBase = 'https://guia.liliaborges.com.br';

  static String? _urlFoto(dynamic item) {
    String? caminho;
    if (item is String) {
      caminho = item;
    } else if (item is Map) {
      for (final chave in ['url', 'caminho', 'arquivo', 'path', 'foto', 'imagem']) {
        if (item[chave] != null) {
          caminho = item[chave].toString();
          break;
        }
      }
    }
    if (caminho == null || caminho.isEmpty) return null;
    if (caminho.startsWith('http')) return caminho;
    return caminho.startsWith('/') ? '$_urlBase$caminho' : '$_urlBase/$caminho';
  }

  static List<String> extrairFotos(dynamic json) {
    dynamic bruto = json;
    if (json is Map) {
      bruto = json['fotos'] ?? json['galeria'] ?? json['imagens'] ?? json['data'] ?? json['foto'] ?? json['imagem'];
    }
    final itens = bruto is List ? bruto : [bruto];
    return itens.map(_urlFoto).whereType<String>().toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'descricao': descricao,
      'categoriaId': categoriaId,
    };
  }
}
