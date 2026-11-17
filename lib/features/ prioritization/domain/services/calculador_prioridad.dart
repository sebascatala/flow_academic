import 'package:flow_academic/features/academic/domain/entities/materia.dart';
import 'package:flow_academic/features/academic/domain/entities/tarea.dart';
import 'package:flow_academic/features/ prioritization/domain/entities/tarea_priorizada.dart';

/// Regla PROVISIONAL de priorización (pesos sin validar con usuarios).
/// Puntaje = suma ponderada de cuatro factores normalizados entre 0 y 1.
class CalculadorPrioridad {
  const CalculadorPrioridad();

  static const double pesoUrgencia = 0.40;
  static const double pesoImportancia = 0.25;
  static const double pesoDificultad = 0.20;
  static const double pesoRendimiento = 0.15;

  /// Una tarea que vence en este número de días o más tiene urgencia 0.
  static const int horizonteDias = 14;
  static const double promedioNeutro = 70;

  /// Devuelve solo las tareas pendientes, ordenadas de mayor a menor prioridad.
  List<TareaPriorizada> ordenar({
    required List<Tarea> tareas,
    required List<Materia> materias,
    DateTime? ahora,
  }) {
    final hoy = _soloFecha(ahora ?? DateTime.now());
    final materiaPorId = {for (final m in materias) m.id: m};

    final calculadas = <TareaPriorizada>[];
    for (final t in tareas) {
      if (t.estado != EstadoTarea.pendiente) continue;
      calculadas.add(_calcular(t, materiaPorId[t.materiaId], hoy));
    }

    calculadas.sort(_comparar);

    return [
      for (var i = 0; i < calculadas.length; i++) calculadas[i].conPosicion(i + 1),
    ];
  }

  TareaPriorizada _calcular(Tarea t, Materia? materia, DateTime hoy) {
    final dias = _soloFecha(t.fechaEntrega).difference(hoy).inDays;
    final urgencia = (1 - dias / horizonteDias).clamp(0.0, 1.0).toDouble();
    final importancia = t.importancia.clamp(1, 5) / 5;
    final dificultad = t.dificultad.clamp(1, 5) / 5;
    final promedio =
    (materia?.promedio ?? promedioNeutro).clamp(0.0, 100.0).toDouble();
    final rendimientoBajo = 1 - promedio / 100;

    final aportes = <String, double>{
      'Fecha de entrega': pesoUrgencia * urgencia,
      'Importancia': pesoImportancia * importancia,
      'Dificultad': pesoDificultad * dificultad,
      'Rendimiento en la materia': pesoRendimiento * rendimientoBajo,
    };
    final puntaje = aportes.values.fold<double>(0, (suma, v) => suma + v);

    return TareaPriorizada(
      tarea: t,
      nombreMateria: materia?.nombre ?? 'Sin materia',
      posicion: 0, // se asigna después de ordenar
      puntaje: puntaje,
      factores: FactoresPrioridad(
        diasRestantes: dias,
        urgencia: urgencia,
        importancia: importancia,
        dificultad: dificultad,
        rendimientoBajo: rendimientoBajo,
      ),
      aportes: aportes,
    );
  }

  /// Mayor puntaje primero; si empatan, la fecha más cercana; luego el título.
  int _comparar(TareaPriorizada a, TareaPriorizada b) {
    final diferencia = b.puntaje - a.puntaje;
    if (diferencia.abs() > 1e-9) return diferencia > 0 ? 1 : -1;
    final porFecha = a.tarea.fechaEntrega.compareTo(b.tarea.fechaEntrega);
    if (porFecha != 0) return porFecha;
    return a.tarea.titulo.compareTo(b.tarea.titulo);
  }

  // UTC para que la diferencia en días no dependa del horario de verano.
  DateTime _soloFecha(DateTime f) => DateTime.utc(f.year, f.month, f.day);
}