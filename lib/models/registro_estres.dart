
import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un único registro de automonitoreo de estrés.
class RegistroEstres {
  final String? id;
  final int nivel; // 1 (muy bajo) a 5 (muy alto)
  final String notas;
  final DateTime fecha;

  RegistroEstres({
    this.id,
    required this.nivel,
    required this.notas,
    required this.fecha,
  });

  factory RegistroEstres.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RegistroEstres(
      id: doc.id,
      nivel: data['nivel'] ?? 3,
      notas: data['notas'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }
}