// UBICACIÓN: lib/data/pausas_predefinidas.dart

import '../models/pausa_activa.dart';

/// Catálogo de pausas activas sugeridas. Al ser contenido curado por ti
/// (no generado por el usuario), se define directamente en el código
/// en vez de guardarlo en Firestore — esto simplifica el alcance del
/// proyecto y evita necesitar un panel de administración aparte.
const List<PausaActiva> pausasPredefinidas = [
  PausaActiva(
    titulo: 'Respiración 4-7-8',
    descripcion:
        'Inhala por la nariz contando hasta 4, sostén el aire contando hasta 7, '
        'y exhala lentamente por la boca contando hasta 8. Repite 4 veces.',
    duracionMinutos: 2,
    categoria: 'respiracion',
    videoUrl: 'https://www.youtube.com/watch?v=4v9N6dAkAKw',
    ritmo: [4, 7, 8],
    ciclos: 4,
  ),
  PausaActiva(
    titulo: 'Respiración diafragmática',
    descripcion:
        'Siéntate derecho, coloca una mano en el pecho y otra en el abdomen. '
        'Respira profundo llenando el abdomen (no el pecho) durante 1 minuto.',
    duracionMinutos: 3,
    categoria: 'respiracion',
    videoUrl: 'https://www.youtube.com/watch?v=WkzMBxohi1M',
    ritmo: [4, 0, 6],
    ciclos: 6,
  ),
  PausaActiva(
    titulo: 'Estiramiento de cuello y hombros',
    descripcion:
        'Inclina la cabeza suavemente hacia cada hombro, sostén 15 segundos '
        'por lado. Luego rota los hombros hacia atrás 10 veces.',
    duracionMinutos: 2,
    categoria: 'estiramiento',
  ),
  PausaActiva(
    titulo: 'Estiramiento de muñecas y manos',
    descripcion:
        'Extiende un brazo con la palma hacia arriba, y con la otra mano tira '
        'suavemente de los dedos hacia atrás. Sostén 15 segundos por mano.',
    duracionMinutos: 2,
    categoria: 'estiramiento',
  ),
  PausaActiva(
    titulo: 'Caminata corta',
    descripcion:
        'Levántate y camina de 3 a 5 minutos, idealmente cambiando de espacio '
        '(ej. salir al pasillo o al patio).',
    duracionMinutos: 5,
    categoria: 'general',
  ),
  PausaActiva(
    titulo: 'Hidratación consciente',
    descripcion:
        'Levántate por un vaso de agua y bébelo despacio, prestando atención '
        'a la sensación, alejándote un momento de la pantalla.',
    duracionMinutos: 2,
    categoria: 'general',
  ),
];