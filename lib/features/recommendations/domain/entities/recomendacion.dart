class Recomendacion {
  final String id;
  final String titulo;
  final String contenido;
  final String categoria; // Ej: "Gestión de Tiempo", "Hábitos de Estudio", "Motivación"
  final DateTime fechaCreacion;

  const Recomendacion({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.categoria,
    required this.fechaCreacion,
  });
}