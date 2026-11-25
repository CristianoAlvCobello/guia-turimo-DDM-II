import 'package:shared_preferences/shared_preferences.dart';
import 'package:guia_turismo/services/session_service.dart';

class FavoritosService {
  Future<String> _chave() async {
    final email = await SessionService().pegarEmail();
    return 'favoritos_$email';
  }

  Future<Set<int>> buscar() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(await _chave()) ?? [];
    return lista.map((id) => int.tryParse(id)).whereType<int>().toSet();
  }

  Future<void> salvar(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(await _chave(), ids.map((id) => '$id').toList());
  }
}
