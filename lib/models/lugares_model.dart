class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String? descricao;
  final int categoriaId;


  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria = '',
    required this.latitude,
    required this.longitude,
    this.descricao = '',
    required this.categoriaId
  });

  //Converter dados json (da api) para Map
  factory LugaresModel.fromJson(Map json) {
    return LugaresModel(
      id: json['id'],
      nome: json['nome'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      descricao: json['descricao'],
      categoria: json['categoria'] is Map ? json['categoria']['nome'] : null,
      categoriaId: json['categoriaId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'descricao': descricao,
      'categoriaId': categoriaId
    };
  }
}
