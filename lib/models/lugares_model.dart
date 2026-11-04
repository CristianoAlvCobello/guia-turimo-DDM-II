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
    required this.categoriaId,
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
    );
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
