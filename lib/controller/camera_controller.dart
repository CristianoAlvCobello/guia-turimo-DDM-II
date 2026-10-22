import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guia_turismo/services/camera_service.dart';

class CameraController extends ChangeNotifier {
  final CameraService _service = CameraService();
  bool carregando = false;
  String? erro;
  File? _imagemSelecionada;
  File? get imagemSelecionada => _imagemSelecionada;

  // Centraliza a seleção para que câmera e galeria atualizem a tela igualmente.
  Future<void> _selecionarImagem(Future<File?> Function() selecionar) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      final imagem = await selecionar();
      if (imagem != null) _imagemSelecionada = imagem;
    } catch (e) {
      erro = 'Não foi possível abrir a imagem. Verifique as permissões.';
      debugPrint('Falha ao selecionar imagem: $e');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> abrirGaleria() => _selecionarImagem(_service.chamarGaleria);

  Future<void> abrirCamera() => _selecionarImagem(_service.chamarCamera);

  void limpar() {
    _imagemSelecionada = null;
    erro = null;
    notifyListeners();
  }
}
