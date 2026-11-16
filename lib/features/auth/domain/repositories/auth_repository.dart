import '../entities/usuario.dart';

abstract class AuthRepository {
  Stream<Usuario?> get authStateChanges;
  Future<Usuario?> getCurrentUser();
  Future<Usuario> signIn({required String email, required String password});
  Future<Usuario> register({
    required String nombre,
    required String email,
    required String password,
    required String carrera,
  });
  Future<void> signOut();
}