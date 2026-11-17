import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tarea.dart';

class TareaModel {
  static Tarea fromMap(Map<String, dynamic> d, String id) => Tarea(
    id: id,
    materiaId: d['materiaId'] as String? ?? '',
    titulo: d['titulo'] as String? ?? '',
    descripcion: d['descripcion'] as String? ?? '',
    fechaEntrega: (d['fechaEntrega'] as Timestamp?)?.toDate() ?? DateTime.now(),
    dificultad: (d['dificultad'] as num?)?.toInt() ?? 3,
    importancia: (d['importancia'] as num?)?.toInt() ?? 3,
    estado: d['estado'] == 'completada'
        ? EstadoTarea.completada
        : EstadoTarea.pendiente,
  );

  static Map<String, dynamic> toMap(Tarea t) => {
    'materiaId': t.materiaId,
    'titulo': t.titulo,
    'descripcion': t.descripcion,
    'fechaEntrega': Timestamp.fromDate(t.fechaEntrega),
    'dificultad': t.dificultad,
    'importancia': t.importancia,
    'estado': t.estado.name, // 'pendiente' o 'completada'
  };
}