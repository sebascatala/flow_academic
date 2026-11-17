import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/repositories/tarea_repository.dart';

class TareasProvider extends ChangeNotifier {
  TareasProvider({required this.repositorio, required this.usuarioId}) {
    _sub = repositorio.observarTareas(usuarioId).listen(
          (lista) {
        _tareas = lista;
        _cargando = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _cargando = false;
        _error = 'No se pudieron cargar las tareas.';
        notifyListeners();
      },
    );
  }

  final TareaRepository repositorio;
  final String usuarioId;
  late final StreamSubscription<List<Tarea>> _sub;
  List<Tarea> _tareas = [];
  bool _cargando = true;
  String? _error;

  List<Tarea> get tareas => _tareas;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> crear(Tarea tarea) => repositorio.crear(usuarioId, tarea);

  Future<void> marcarCompletada(String tareaId) =>
      repositorio.marcarCompletada(usuarioId, tareaId);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}