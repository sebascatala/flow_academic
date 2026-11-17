import 'package:flutter_test/flutter_test.dart';
import 'package:flow_academic/features/academic/domain/entities/materia.dart';
import 'package:flow_academic/features/academic/domain/entities/tarea.dart';
import 'package:flow_academic/features/ prioritization/domain/services/calculador_prioridad.dart';

void main() {
  const calculador = CalculadorPrioridad();
  final hoy = DateTime(2026, 11, 16);

  const calculo = Materia(
      id: 'cal', nombre: 'Cálculo II', codigo: 'MAT-201',
      docente: 'Docente', creditos: 5, promedio: 40);
  const historia = Materia(
      id: 'his', nombre: 'Historia', codigo: 'HUM-101',
      docente: 'Docente', creditos: 3, promedio: 90);
  const materias = [calculo, historia];

  Tarea tarea(String id, String materia, int dias,
      {int dif = 3, int imp = 3, EstadoTarea estado = EstadoTarea.pendiente}) =>
      Tarea(
        id: id,
        materiaId: materia,
        titulo: 'Tarea $id',
        fechaEntrega: hoy.add(Duration(days: dias)),
        dificultad: dif,
        importancia: imp,
        estado: estado,
      );

  List<String> ids(List<dynamic> lista) =>
      lista.map<String>((p) => p.tarea.id as String).toList();

  test('CA-06: B (difícil, importante, rendimiento bajo) queda sobre A aunque A vence antes', () {
    final a = tarea('A', 'his', 2, dif: 1, imp: 1);
    final b = tarea('B', 'cal', 5, dif: 5, imp: 5);

    final r = calculador.ordenar(tareas: [a, b], materias: materias, ahora: hoy);

    expect(ids(r), ['B', 'A']);
    expect(r.map((p) => p.posicion), [1, 2]);
    expect(r[0].puntaje, closeTo(0.797, 0.001));
    expect(r[1].puntaje, closeTo(0.448, 0.001));
  });

  test('CA-07: al agregar una tarea la lista se recalcula', () {
    final a = tarea('A', 'his', 2, dif: 1, imp: 1);
    final b = tarea('B', 'cal', 5, dif: 5, imp: 5);

    final antes = calculador.ordenar(tareas: [a], materias: materias, ahora: hoy);
    final despues = calculador.ordenar(tareas: [a, b], materias: materias, ahora: hoy);

    expect(ids(antes), ['A']);
    expect(ids(despues), ['B', 'A']);
  });

  test('CA-08: las tareas completadas no aparecen en la lista', () {
    final a = tarea('A', 'his', 2, estado: EstadoTarea.completada);
    final b = tarea('B', 'cal', 5);

    final r = calculador.ordenar(tareas: [a, b], materias: materias, ahora: hoy);

    expect(ids(r), ['B']);
  });

  test('una tarea vencida tiene urgencia máxima', () {
    final r = calculador.ordenar(
        tareas: [tarea('V', 'cal', -2)], materias: materias, ahora: hoy);

    expect(r.first.factores.urgencia, 1.0);
    expect(r.first.factores.diasRestantes, -2);
  });

  test('empate de puntaje: gana la fecha de entrega más cercana', () {
    final lejos = tarea('lejos', 'cal', 30);
    final cerca = tarea('cerca', 'cal', 20); // ambas con urgencia 0

    final r = calculador.ordenar(
        tareas: [lejos, cerca], materias: materias, ahora: hoy);

    expect(ids(r), ['cerca', 'lejos']);
  });

  test('materia desconocida no falla y usa el promedio neutro', () {
    final r = calculador.ordenar(
        tareas: [tarea('X', 'no-existe', 3)], materias: materias, ahora: hoy);

    expect(r.single.nombreMateria, 'Sin materia');
    expect(r.single.factores.rendimientoBajo, closeTo(0.3, 0.0001));
  });

  test('sin tareas devuelve una lista vacía', () {
    expect(calculador.ordenar(tareas: [], materias: materias, ahora: hoy), isEmpty);
  });
}