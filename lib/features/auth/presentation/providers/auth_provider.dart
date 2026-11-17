import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider({required this.authRepository});

  Usuario? _usuario;
  bool _isLoading = false;
  String? _errorMessage;

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _usuario = await authRepository.signIn(
        email: email,
        password: password,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    _usuario = null;
    notifyListeners();
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    required String carrera,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _usuario = await authRepository.register(
        nombre: nombre,
        email: email,
        password: password,
        carrera: carrera,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> cargarSesion() async {
    try {
      _usuario = await authRepository.getCurrentUser();
    } catch (_) {
      _usuario = null;
    }
    notifyListeners();
  }
}