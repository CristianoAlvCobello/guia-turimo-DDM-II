import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:guia_turismo/services/lugares_services.dart';
import 'package:guia_turismo/services/session_service.dart';

class LugaresController extends ChangeNotifier {
  bool carregando = false;
  String erro = "";
  String mensagem = "";
  List<LugaresModel> _lugares = [];
  List<LugaresModel> get lugares => _lugares;

  LugaresController() {
    listaLugares();
  }

  Future<void> listaLugares() async {
    carregando = true;
    erro = "";
    notifyListeners();
    try {
      final lugaresService = LugaresServices();
      final listaLugares = await lugaresService.buscarLugares();
      _lugares = listaLugares;
    } catch (error) {
      erro = "Erro ao listar: ${error.toString()}";
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrarLugar(
    LugaresModel dados, {
    Uint8List? foto,
    String? nomeFoto,
  }) async {
    final token = await SessionService().pegarToken() ?? '';
    carregando = true;
    mensagem = "";
    notifyListeners();

    try {
      final lugaresService = LugaresServices();
      final resultado = await lugaresService.cadastrarLugar(dados, token);
      mensagem = resultado['message'].toString();

      if (foto != null) {
        try {
          int? id = resultado['id'] as int?;
          id ??= await lugaresService.buscarIdPorNome(dados.nome);
          if (id == null) {
            throw Exception('não foi possível identificar o lugar criado');
          }
          await lugaresService.enviarFoto(id, foto, nomeFoto ?? 'foto.jpg', token);
          mensagem = 'Lugar e foto cadastrados com sucesso!';
        } catch (e) {
          mensagem =
              'Lugar cadastrado, mas a foto não foi enviada: ${e.toString().replaceFirst('Exception: ', '')}';
        }
      }
      return true;
    } catch (e) {
      mensagem = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
