import '../entities/materia.dart';

// Firestore: usuarios/{usuarioId}/materias/{materiaId}
abstract class MateriaRepository {
  Stream<List<Materia>> observarMaterias(String usuarioId);
  Future<void> crear(String usuarioId, Materia materia);
}