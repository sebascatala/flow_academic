class Materia {
  final String id;
  final String nombre;
  final String codigo;
  final String docente;
  final int creditos;

  /// Rendimiento actual en la materia, de 0 a 100. Lo escribe el usuario.
  /// 70 es un valor neutro si no lo ingresó.
  final double promedio;

  const Materia({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.docente,
    required this.creditos,
    this.promedio = 70,
  });

  @override
  bool operator ==(Object other) => other is Materia && other.id == id;

  @override
  int get hashCode => id.hashCode;
}