// UBICACIÓN: lib/widgets/encabezado_uts.dart (junto a aparecer.dart)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'aparecer.dart';

/// Encabezado con degradado gris institucional, título, línea verde limón
/// y subtítulo opcional. Reemplaza a la barra superior (AppBar) simple para
/// que las pantallas internas se vean igual que el login, el registro y el Home.
class EncabezadoUTS extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final bool mostrarVolver;

  const EncabezadoUTS({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.mostrarVolver = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Íconos claros en la barra de estado, porque el fondo es oscuro.
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          8,
          MediaQuery.of(context).padding.top + 8,
          24,
          28,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2B2B2D),
              ColoresUTS.grisOscuro,
              Color(0xFF55575A),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mostrarVolver)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Volver',
                onPressed: () => Navigator.of(context).pop(),
              )
            else
              const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Aparecer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColoresUTS.verde,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitulo!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

    