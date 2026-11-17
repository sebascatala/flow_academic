import 'package:flow_academic/features/academic/domain/validadores_tarea.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  final hoy = DateTime(2026, 11, 16);

  test('CA-03: sin dificultad se rechaza con el mensaje exacto', () {
    expect(ValidadoresTarea.dificultad(null), 'Elige una dificultad del 1 al 5.');
  });
  test('dificultad 3 se acepta', () {
    expect(ValidadoresTarea.dificultad(3), isNull);
  });
  test('título de solo espacios se rechaza', () {
    expect(ValidadoresTarea.titulo('   '), isNotNull);
  });
  test('porcentaje con coma decimal se acepta', () {
    expect(ValidadoresTarea.porcentaje('15,5'), isNull);
  });
  test('porcentaje mayor a 100 se rechaza', () {
    expect(ValidadoresTarea.porcentaje('150'), isNotNull);
  });
  test('fecha pasada se rechaza y la de hoy se acepta', () {
    expect(ValidadoresTarea.fecha(DateTime(2026, 11, 15), hoy: hoy), isNotNull);
    expect(ValidadoresTarea.fecha(DateTime(2026, 11, 16), hoy: hoy), isNull);
  });
}