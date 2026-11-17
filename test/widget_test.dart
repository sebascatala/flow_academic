import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flow_academic/features/auth/domain/entities/usuario.dart';
import 'package:flow_academic/features/auth/domain/repositories/auth_repository.dart';
import 'package:flow_academic/features/auth/presentation/pages/login_page.dart';
import 'package:flow_academic/features/auth/presentation/providers/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<Usuario?> get authStateChanges => const Stream.empty();

  @override
  Future<Usuario?> getCurrentUser() async => null;

  @override
  Future<Usuario> register({
    required String nombre,
    required String email,
    required String password,
    required String carrera,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Usuario> signIn({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('LoginPage renderiza correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authRepository: FakeAuthRepository()),
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    expect(find.text('Flow Academic'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}