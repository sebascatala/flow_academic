import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/tarea_repository.dart';
import '../models/tarea_model.dart';

class FirestoreTareaRepository implements TareaRepository {
  FirestoreTareaRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('usuarios').doc(uid).collection('tareas');

  @override
  Stream<List<Tarea>> observarTareas(String usuarioId) =>
      _col(usuarioId).snapshots().map((s) =>
          s.docs.map((d) => TareaModel.fromMap(d.data(), d.id)).toList());

  @override
  Future<void> crear(String usuarioId, Tarea tarea) =>
      _col(usuarioId).doc(tarea.id).set(TareaModel.toMap(tarea));

  @override
  Future<void> marcarCompletada(String usuarioId, String tareaId) =>
      _col(usuarioId).doc(tareaId).update({'estado': 'completada'});
}