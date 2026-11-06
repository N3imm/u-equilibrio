
import 'package:flutter/material.dart';

/// Hace que su contenido aparezca con un fundido y un leve deslizamiento
/// hacia arriba al mostrarse en pantalla. Usa solo animaciones nativas de
/// Flutter (sin paquetes externos).
///
/// [retrasoMs] permite escalonar la entrada de varios elementos: el primero
/// con 0, el siguiente con 150, el siguiente con 300, etc.
class Aparecer extends StatelessWidget {
  final Widget child;
  final int retrasoMs;
  final int duracionMs;

  const Aparecer({
    super.key,
    required this.child,
    this.retrasoMs = 0,
    this.duracionMs = 600,
  });

  @override
  Widget build(BuildContext context) {
    final total = retrasoMs + duracionMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: total),
      // El Interval hace que la animación "espere" el retraso indicado
      // y luego se ejecute durante el resto del tiempo.
      curve: Interval(retrasoMs / total, 1.0, curve: Curves.easeOutCubic),
      builder: (context, valor, hijo) {
        return Opacity(
          opacity: valor,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - valor)),
            child: hijo,
          ),
        );
      },
      child: child,
    );
  }
}