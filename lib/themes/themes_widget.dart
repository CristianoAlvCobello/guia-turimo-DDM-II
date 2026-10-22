import 'package:flutter/material.dart';

AppBarTheme defineAppBar(cor) {
  return AppBarTheme(
    centerTitle: true,
    backgroundColor: cor.surface,
    foregroundColor: cor.onSurface,
    elevation: 0,
  );
}

BottomNavigationBarThemeData defineNavegacaoBase(cor) {
  return BottomNavigationBarThemeData(
    backgroundColor: cor.primary,
    elevation: 0,
  );
}

ElevatedButtonThemeData defineBotaoElevated(cor) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: cor.primary,
      foregroundColor: cor.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
