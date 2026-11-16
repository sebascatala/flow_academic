import 'materia.dart';
class Nota{
  final String id;
  final Materia materia;
  final String titulo; // Ej: "Examen Parcial 1", "Práctica 3"
  final double calificacionObtenida; // Ej: 85.0
  final double calificacionMaxima;   // Ej: 100.0
  final double pesoPorcentual;     // Ej: 20.0 (vale 20% de la materia)
  final DateTime fechaRegistro;

  const Nota({
    required this.id,
    required this.materia,
    required this.titulo,
    required this.calificacionObtenida,
    required this.calificacionMaxima,
    required this.pesoPorcentual,
    required this.fechaRegistro,
  });

  // Utilidad para calcular el puntaje ponderado obtenido
  double get puntajePonderado => (calificacionObtenida / calificacionMaxima) * pesoPorcentual;
}
