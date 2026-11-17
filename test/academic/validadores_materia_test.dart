import 'package:flutter_test/flutter_test.dart';
import 'package:flow_academic/features/academic/domain/validadores_tarea.dart';
import 'package:flow_academic/features/academic/domain/validadores_materia.dart';

void main() {
  test('nombre vacío se rechaza', () {
    expect(ValidadoresMateria.nombre('  '), isNotNull);
  });
  test('promedio vacío es válido (opcional)', () {
    expect(ValidadoresMateria.promedio(''), isNull);
  });
  test('promedio mayor a 100 se rechaza', () {
    expect(ValidadoresMateria.promedio('120'), isNotNull);
  });
  test('promedio con coma decimal se acepta', () {
    expect(ValidadoresMateria.promedio('85,5'), isNull);
  });
}