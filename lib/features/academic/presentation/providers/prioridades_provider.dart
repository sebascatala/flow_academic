import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flow_academic/features/academic/domain/entities/materia.dart';
import 'package:flow_academic/features/academic/domain/entities/tarea.dart';
import 'package:flow_academic/features/academic/domain/repositories/materia_repository.dart';
import 'package:flow_academic/features/academic/domain/repositories/tarea_repository.dart';
import 'package:flow_academic/features/ prioritization/domain/entities/tarea_priorizada.dart';
import 'package:flow_academic/features/ prioritization/domain/services/calculador_prioridad.dart';

class PrioridadesProvider extends ChangeNotifier {
  PrioridadesProvider({
    required this.tareaRepositorio,
    required this.materiaRepositorio,
    required this.usuarioId,
    this.calculador = const CalculadorPrioridad(),
  }) {
    _subTareas = tareaRepositorio.observarTareas(usuarioId).listen(
          (lista) {
        _tareas = lista;
        _tareasListas = true;
        _recalcular();
      },
      onError: (_) => _fallar(),
    );
    _subMaterias = materiaRepositorio.observarMaterias(usuarioId).listen(
          (lista) {
        _materias = lista;
        _materiasListas = true;
        _recalcular();
      },
      onError: (_) => _fallar(),
    );
  }

  final TareaRepository tareaRepositorio;
  final MateriaRepository materiaRepositorio;
  final String usuarioId;
  final CalculadorPrioridad calculador;

  late final StreamSubscription<List<Tarea>> _subTareas;
  late final StreamSubscription<List<Materia>> _subMaterias;

  List<Tarea> _tareas = [];
  List<Materia> _materias = [];
  List<TareaPriorizada> _prioridades = [];
  bool _tareasListas = false;
  bool _materiasListas = false;
  String? _error;

  List<TareaPriorizada> get prioridades => _prioridades;
  bool get cargando => !(_tareasListas && _materiasListas);
  String? get error => _error;

  /// Puesto de una tarea en la lista actual (1 = atender primero), o null si no está.
  int? posicionDe(String tareaId) {
    for (final p in _prioridades) {
      if (p.tarea.id == tareaId) return p.posicion;
    }
    return null;
  }

  /// CA-08: la tarea sale de la lista porque el cálculo solo incluye pendientes.
  Future<void> completar(String tareaId) =>
      tareaRepositorio.marcarCompletada(usuarioId, tareaId);

  void _recalcular() {
    _prioridades = calculador.ordenar(tareas: _tareas, materias: _materias);
    _error = null;
    notifyListeners();
  }

  void _fallar() {
    _tareasListas = true;
    _materiasListas = true;
    _error = 'No se pudieron cargar tus tareas. Revisa tu conexión.';
    notifyListeners();
  }

  @override
  void dispose() {
    _subTareas.cancel();
    _subMaterias.cancel();
    super.dispose();
  }
}