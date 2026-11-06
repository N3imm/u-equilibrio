
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aparecer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;
  bool _ocultarPassword = true;
  bool _aceptaTratamientoDatos = false;
  String? _errorMensaje;

  Future<void> _manejarRegistro() async {
    if (_cargando || !_aceptaTratamientoDatos) return;
    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    String? error;
    try {
      error = await _authService.registrarUsuario(
        _emailController.text,
        _passwordController.text,
        aceptoTratamientoDatos: _aceptaTratamientoDatos,
      );
    } catch (e) {
      // Garantiza que el botón nunca se quede cargando para siempre.
      error = 'No se pudo completar el registro: $e';
    }

    if (!mounted) return;

    if (error == null) {
      // Registro exitoso: Firebase ya deja al usuario con sesión iniciada.
      // main.dart (StreamBuilder) lo llevará a Home automáticamente.
      Navigator.of(context).pop();
    } else {
      setState(() {
        _cargando = false;
        _errorMensaje = error;
      });
    }
  }

  void _mostrarPolitica() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tratamiento de datos personales'),
        content: const SingleChildScrollView(
          child: Text(
            'U-Equilibrio es una aplicación desarrollada como proyecto de '
            'grado en las Unidades Tecnológicas de Santander (UTS).\n\n'
            'Finalidad: registrar tu nivel de estrés académico y sugerirte '
            'pausas activas.\n\n'
            'Datos que se recolectan: tu correo electrónico, los niveles de '
            'estrés que registres, las notas que escribas y la fecha y hora '
            'de cada registro.\n\n'
            'Uso: tus datos se usan únicamente con fines académicos del '
            'proyecto. Dentro de la app solo tú puedes ver tus registros, y '
            'los resultados que se presenten serán anónimos.\n\n'
            'Almacenamiento: tus datos se guardan en Firebase (Google Cloud), '
            'cuyos servidores pueden estar fuera de Colombia.\n\n'
            'Tus derechos (Ley 1581 de 2012): puedes conocer, actualizar, '
            'rectificar y solicitar la supresión de tus datos.\n\n'
            'Importante: esta app no reemplaza la atención psicológica '
            'profesional. Si sientes que necesitas ayuda, acude a Bienestar '
            'Universitario.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _aceptaTratamientoDatos = true);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Acepto'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Encabezado compacto con degradado institucional, botón de volver y logo.
  Widget _encabezado(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 8,
        24,
        32,
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Volver',
            onPressed: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Aparecer(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 52,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.self_improvement,
                        size: 44,
                        color: ColoresUTS.verde,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Crea tu cuenta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: ColoresUTS.verde,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Únete a U-Equilibrio y empieza tu seguimiento',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mensaje de error que aparece suavemente (se expande al mostrarse).
  Widget _mensajeError() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: _errorMensaje == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMensaje!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Casilla de consentimiento informado con acceso a la política completa.
  Widget _casillaConsentimiento() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _aceptaTratamientoDatos
              ? ColoresUTS.verde
              : Colors.grey.shade300,
          width: _aceptaTratamientoDatos ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _aceptaTratamientoDatos,
            activeColor: ColoresUTS.verde,
            checkColor: ColoresUTS.grisOscuro,
            onChanged: (valor) =>
                setState(() => _aceptaTratamientoDatos = valor ?? false),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acepto el tratamiento de mis datos personales para los '
                    'fines académicos de este proyecto.',
                    style: TextStyle(fontSize: 13),
                  ),
                  TextButton(
                    onPressed: _mostrarPolitica,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    child: const Text(
                      'Leer la política de tratamiento de datos',
                      style: TextStyle(
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Íconos claros en la barra de estado, porque el fondo es oscuro.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              _encabezado(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Aparecer(
                  retrasoMs: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Tus datos de acceso',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColoresUTS.grisOscuro,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _ocultarPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _manejarRegistro(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          helperText: 'Mínimo 6 caracteres',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _ocultarPassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            icon: Icon(
                              _ocultarPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _ocultarPassword = !_ocultarPassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _casillaConsentimiento(),
                      _mensajeError(),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          // Solo se habilita si el usuario aceptó el
                          // tratamiento de datos y no hay un registro en curso.
                          onPressed: (_cargando || !_aceptaTratamientoDatos)
                              ? null
                              : _manejarRegistro,
                          child: _cargando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: ColoresUTS.grisOscuro,
                                  ),
                                )
                              : const Text('Registrarme'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}