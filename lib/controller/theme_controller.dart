import 'package:flutter/material.dart';
import 'package:guia_turismo/themes/themes_widget.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _temaAtual = ThemeMode.light;
  ThemeMode get temaAtual => _temaAtual;

  IconData get iconeAtual =>
      _temaAtual == ThemeMode.light ? Icons.light_mode : Icons.dark_mode;

  static ThemeData _mudarTema(Brightness brilho) {
    final cor = ColorScheme.fromSeed(
      seedColor: const Color(0xFF167D77),
      brightness: brilho,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cor,
      scaffoldBackgroundColor: cor.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cor.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      appBarTheme: defineAppBar(cor),
      bottomNavigationBarTheme: defineNavegacaoBase(cor),
      elevatedButtonTheme: defineBotaoElevated(cor),
      iconButtonTheme: IconButtonThemeData(),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cor.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  ThemeData temaClaro() => _mudarTema(Brightness.light);
  ThemeData temaEscuro() => _mudarTema(Brightness.dark);

  void alternarTema() {
    _temaAtual = _temaAtual == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners(); // Atualiza as telas que utilizam o tema.
  }
}
