import '../entities/tarea.dart';

// Firestore: usuarios/{usuarioId}/tareas/{tareaId}
abstract class TareaRepository {
  /// Emite la lista completa cada vez que cambia algo (así la lista se reordena sola, CA-07).
  Stream<List<Tarea>> observarTareas(String usuarioId);
  Future<void> crear(String usuarioId, Tarea tarea);
  Future<void> marcarCompletada(String usuarioId, String tareaId);
}