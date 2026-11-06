
import 'package:flutter/material.dart';

/// Representación visual de los 5 niveles de estrés. Se define en un solo
/// lugar para que todas las pantallas muestren siempre lo mismo.
/// El nivel 1 corresponde a la posición 0 de cada lista.
class NivelesEstres {
  static const List<String> emojis = ['😄', '🙂', '😐', '😟', '😫'];

  static const List<String> etiquetas = [
    'Muy bajo',
    'Bajo',
    'Medio',
    'Alto',
    'Muy alto',
  ];

  /// Color de cada nivel: va de verde (calma) a rojo (estrés muy alto),
  /// pasando por el verde limón institucional de la UTS.
  static const List<Color> colores = [
    Color(0xFF43A047), // 1 - verde
    Color(0xFFC3D700), // 2 - verde limón UTS
    Color(0xFFFFB300), // 3 - ámbar
    Color(0xFFFB8C00), // 4 - naranja
    Color(0xFFE53935), // 5 - rojo
  ];
}