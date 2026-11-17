import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/usuario_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<Usuario?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await getCurrentUser();
    });
  }

  @override
  Future<Usuario?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return UsuarioModel.fromMap(doc.data()!, user.uid);
  }

  @override
  Future<Usuario> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('No se encontraron los datos del usuario.');
      }
      return UsuarioModel.fromMap(doc.data()!, uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensajeDe(e));
    }
  }

  @override
  Future<Usuario> register({
    required String nombre,
    required String email,
    required String password,
    required String carrera,
  }) async {
    UserCredential credential;
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mensajeDe(e));
    }

    final uid = credential.user!.uid;
    final nuevoUsuario = UsuarioModel(
      id: uid,
      nombre: nombre,
      email: email,
      carrera: carrera,
    );

    try {
      await _firestore.collection('usuarios').doc(uid).set(nuevoUsuario.toMap());
    } catch (_) {
      // Si falla el guardado, se borra la cuenta para no dejar un usuario sin datos
      await credential.user!.delete();
      throw Exception('No se pudo completar el registro. Intenta de nuevo.');
    }
    return nuevoUsuario;
  }

  String _mensajeDe(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'network-request-failed':
        return 'Sin conexión. Revisa tu internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      default:
        return 'No se pudo completar la operación. Intenta de nuevo.';
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}