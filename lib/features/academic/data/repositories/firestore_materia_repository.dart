import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/materia.dart';
import '../../domain/repositories/materia_repository.dart';
import '../models/materia_model.dart';

class FirestoreMateriaRepository implements MateriaRepository {
  FirestoreMateriaRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('usuarios').doc(uid).collection('materias');

  @override
  Stream<List<Materia>> observarMaterias(String usuarioId) =>
      _col(usuarioId).snapshots().map((s) =>
          s.docs.map((d) => MateriaModel.fromMap(d.data(), d.id)).toList());

  @override
  Future<void> crear(String usuarioId, Materia materia) =>
      _col(usuarioId).doc(materia.id).set(MateriaModel.toMap(materia));
}