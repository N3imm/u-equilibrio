

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/registro_estres.dart';

/// Guarda y lee los registros de estrés del usuario que tiene
/// la sesión iniciada en ese momento, usando Firestore.
class EstresService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _coleccion {
    return _db.collection('usuarios').doc(_uid).collection('registros_estres');
  }

  Future<void> guardarRegistro(int nivel, String notas) async {
    if (_uid == null) return;
    await _coleccion.add({
      'nivel': nivel,
      'notas': notas,
      'fecha': Timestamp.now(),
    });
  }

  /// Stream en tiempo real: la lista se actualiza sola en pantalla
  /// cada vez que se guarda un nuevo registro, sin recargar nada.
  Stream<List<RegistroEstres>> streamRegistros() {
    if (_uid == null) return const Stream.empty();
    return _coleccion
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => RegistroEstres.fromDoc(d)).toList());
  }
}