import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/materia.dart';
import '../../domain/repositories/materia_repository.dart';

class MateriasProvider extends ChangeNotifier {
  MateriasProvider({required this.repositorio, required this.usuarioId}) {
    _sub = repositorio.observarMaterias(usuarioId).listen(
          (lista) {
        _materias = lista;
        _cargando = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _cargando = false;
        _error = 'No se pudieron cargar las materias.';
        notifyListeners();
      },
    );
  }

  final MateriaRepository repositorio;
  final String usuarioId;
  late final StreamSubscription<List<Materia>> _sub;
  List<Materia> _materias = [];
  bool _cargando = true;
  String? _error;

  List<Materia> get materias => _materias;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> crear(Materia materia) => repositorio.crear(usuarioId, materia);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}