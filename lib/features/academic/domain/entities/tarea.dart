import 'materia.dart';

enum EstadoTarea { pendiente, enProgreso, completada }

class Tarea {
  final String id;
  final Materia materia; // Relación directa con la entidad Materia
  final String titulo;
  final String descripcion;
  final DateTime fechaEntrega;
  final double porcentajeNota; // Ej: 15.0 (vale 15% de la nota final)
  final int dificultad;
  final EstadoTarea estado;

  const Tarea({
    required this.id,
    required this.materia,
    required this.titulo,
    this.descripcion = '',
    required this.fechaEntrega,
    required this.porcentajeNota,
    required this.dificultad,
    this.estado = EstadoTarea.pendiente,
  });
}