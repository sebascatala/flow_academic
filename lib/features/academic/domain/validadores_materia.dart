class ValidadoresMateria {
  static String? nombre(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Escribe el nombre de la materia.' : null;

  /// Opcional: vacío es válido (se usará el valor neutro).
  static String? promedio(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final n = double.tryParse(t.replaceAll(',', '.'));
    if (n == null) return 'Ingresa un número válido.';
    if (n < 0 || n > 100) return 'El promedio debe estar entre 0 y 100.';
    return null;
  }

  /// Opcional: vacío es válido.
  static String? creditos(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null) return 'Ingresa un número entero.';
    if (n < 0) return 'Los créditos no pueden ser negativos.';
    return null;
  }
}