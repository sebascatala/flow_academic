class ValidadoresTarea {
  static String? titulo(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Escribe un título para la tarea.' : null;

  static String? materia(Object? v) => v == null ? 'Elige una materia.' : null;

  // CA-03: mensaje exacto del prototipo
  static String? dificultad(int? v) =>
      (v == null || v < 1 || v > 5) ? 'Elige una dificultad del 1 al 5.' : null;

  static String? porcentaje(String? v) {
    final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (n == null) return 'Ingresa un número válido.';
    if (n < 0 || n > 100) return 'El porcentaje debe estar entre 0 y 100.';
    return null;
  }

  static String? fecha(DateTime? f, {DateTime? hoy}) {
    if (f == null) return 'Elige la fecha de entrega.';
    final h = hoy ?? DateTime.now();
    final inicioDeHoy = DateTime(h.year, h.month, h.day);
    return f.isBefore(inicioDeHoy) ? 'La fecha de entrega no puede estar en el pasado.' : null;
  }
  static String? importancia(int? v) =>
      (v == null || v < 1 || v > 5) ? 'Elige una importancia del 1 al 5.' : null;
}