

import '../models/registro_estres.dart';

/// Resumen de un día para el gráfico semanal.
class DiaResumen {
  final DateTime dia;

  /// Promedio de los niveles registrados ese día (1 a 5).
  /// Es null si ese día no hubo ningún registro.
  final double? promedio;

  /// Cuántos registros se hicieron ese día.
  final int cantidad;

  const DiaResumen({
    required this.dia,
    required this.promedio,
    required this.cantidad,
  });
}

/// Deja solo la fecha (año, mes, día), sin la hora.
DateTime _soloDia(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

/// Cuenta los días seguidos en los que el usuario registró su estado.
///
/// La racha sigue "viva" si el último registro fue hoy o ayer: así el
/// usuario no la pierde antes de que termine el día en que aún puede
/// registrar. Si el último registro fue antes de ayer, la racha es 0.
int calcularRacha(List<RegistroEstres> registros, {DateTime? ahora}) {
  final hoy = _soloDia(ahora ?? DateTime.now());
  final diasConRegistro = registros.map((r) => _soloDia(r.fecha)).toSet();

  var dia = diasConRegistro.contains(hoy)
      ? hoy
      : DateTime(hoy.year, hoy.month, hoy.day - 1);

  var racha = 0;
  while (diasConRegistro.contains(dia)) {
    racha++;
    dia = DateTime(dia.year, dia.month, dia.day - 1);
  }
  return racha;
}

/// Devuelve 7 resúmenes, uno por cada uno de los últimos 7 días,
/// ordenados del más antiguo al más reciente (el último es hoy).
List<DiaResumen> resumenSemanal(List<RegistroEstres> registros,
    {DateTime? ahora}) {
  final hoy = _soloDia(ahora ?? DateTime.now());

  return List.generate(7, (i) {
    final dia = DateTime(hoy.year, hoy.month, hoy.day - (6 - i));
    final delDia = registros.where((r) => _soloDia(r.fecha) == dia).toList();

    if (delDia.isEmpty) {
      return DiaResumen(dia: dia, promedio: null, cantidad: 0);
    }

    final suma = delDia.fold<int>(0, (total, r) => total + r.nivel);
    return DiaResumen(
      dia: dia,
      promedio: suma / delDia.length,
      cantidad: delDia.length,
    );
  });
}