import '../../domain/entities/materia.dart';

class MateriaModel {
  static Materia fromMap(Map<String, dynamic> d, String id) => Materia(
    id: id,
    nombre: d['nombre'] as String? ?? '',
    codigo: d['codigo'] as String? ?? '',
    docente: d['docente'] as String? ?? '',
    creditos: (d['creditos'] as num?)?.toInt() ?? 0,
    promedio: (d['promedio'] as num?)?.toDouble() ?? 70,
  );

  static Map<String, dynamic> toMap(Materia m) => {
    'nombre': m.nombre,
    'codigo': m.codigo,
    'docente': m.docente,
    'creditos': m.creditos,
    'promedio': m.promedio,
  };
}