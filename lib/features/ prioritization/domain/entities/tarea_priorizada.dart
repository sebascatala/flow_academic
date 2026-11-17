import 'package:flow_academic/features/academic/domain/entities/tarea.dart';

/// Los factores ya normalizados (0 a 1), para explicar «¿Por qué este orden?».
class FactoresPrioridad {
  final int diasRestantes; // negativo si ya venció
  final double urgencia;
  final double importancia;
  final double dificultad;
  final double rendimientoBajo; // más alto = peor rendimiento en la materia

  const FactoresPrioridad({
    required this.diasRestantes,
    required this.urgencia,
    required this.importancia,
    required this.dificultad,
    required this.rendimientoBajo,
  });
}

class TareaPriorizada {
  final Tarea tarea;
  final String nombreMateria;
  final int posicion; // 1 = atender primero
  final double puntaje; // 0 a 1
  final FactoresPrioridad factores;

  /// Cuánto aportó cada factor al puntaje, ya ponderado.
  final Map<String, double> aportes;

  const TareaPriorizada({
    required this.tarea,
    required this.nombreMateria,
    required this.posicion,
    required this.puntaje,
    required this.factores,
    required this.aportes,
  });

  TareaPriorizada conPosicion(int nuevaPosicion) => TareaPriorizada(
    tarea: tarea,
    nombreMateria: nombreMateria,
    posicion: nuevaPosicion,
    puntaje: puntaje,
    factores: factores,
    aportes: aportes,
  );
}