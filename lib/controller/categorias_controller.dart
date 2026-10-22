import 'package:flutter/material.dart';
import 'package:guia_turismo/models/categoria_model.dart';
import 'package:guia_turismo/services/categorias_service.dart';

class CategoriasController extends ChangeNotifier {
  bool carregando = false;
  String erro = "";
  List<CategoriaModel> _categorias = [];
  List<CategoriaModel> get categorias => _categorias;

  CategoriasController() {
    listaCategorias();
  }

  Future<void> listaCategorias() async {
    carregando = true;
    erro = "";
    notifyListeners();
    try {
      _categorias = await CategoriasService().buscarCategorias();
    } catch (error) {
      erro = "Erro ao listar categorias: ${error.toString()}";
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
