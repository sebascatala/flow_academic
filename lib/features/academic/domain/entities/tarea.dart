enum EstadoTarea { pendiente, completada }

class Tarea {
  final String id;
  final String materiaId;
  final String titulo;
  final String descripcion;
  final DateTime fechaEntrega;
  final int dificultad; // 1 a 5
  final int importancia; // 1 a 5
  final EstadoTarea estado;

  const Tarea({
    required this.id,
    required this.materiaId,
    required this.titulo,
    required this.fechaEntrega,
    required this.dificultad,
    required this.importancia,
    this.descripcion = '',
    this.estado = EstadoTarea.pendiente,
  });

  Tarea copyWith({EstadoTarea? estado}) => Tarea(
    id: id,
    materiaId: materiaId,
    titulo: titulo,
    descripcion: descripcion,
    fechaEntrega: fechaEntrega,
    dificultad: dificultad,
    importancia: importancia,
    estado: estado ?? this.estado,
  );
}