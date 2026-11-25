import 'package:material_ui/material_ui.dart';
import 'package:guia_turismo/services/favoritos_service.dart';

class FavoritosController extends ChangeNotifier {
  Set<int> _ids = {};

  bool ehFavorito(int id) => _ids.contains(id);

  Future<void> carregar() async {
    _ids = await FavoritosService().buscar();
    notifyListeners();
  }

  Future<void> alternar(int id) async {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    await FavoritosService().salvar(_ids);
  }
}
