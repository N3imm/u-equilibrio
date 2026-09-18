
import 'package:firebase_auth/firebase_auth.dart';

/// Esta clase centraliza toda la comunicación con Firebase Authentication.
/// Las pantallas (login_screen, register_screen) solo llaman a estos métodos,
/// sin tener que conocer los detalles de FirebaseAuth directamente.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream que emite el usuario actual cada vez que cambia
  /// (inicia sesión, cierra sesión, etc). main.dart lo usa para
  /// decidir si mostrar el Login o la pantalla principal.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get usuarioActual => _auth.currentUser;

  /// Registra un nuevo usuario. Devuelve null si todo salió bien,
  /// o un mensaje de error legible si algo falló.
  Future<String?> registrarUsuario(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e.code);
    }
  }

  /// Inicia sesión con un usuario ya registrado.
  Future<String?> iniciarSesion(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _traducirError(e.code);
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  /// Traduce los códigos de error de Firebase a mensajes en español,
  /// más claros para el usuario final de tu app.
  String _traducirError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Ese correo ya está registrado.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      default:
        return 'Ocurrió un error: $code';
    }
  }
}