import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.paginaPrincipal});
  final Widget paginaPrincipal;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<void> _sesion;

  @override
  void initState() {
    super.initState();
    _sesion = context.read<AuthProvider>().cargarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _sesion,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final usuario = context.watch<AuthProvider>().usuario;
        return usuario == null ? const LoginPage() : widget.paginaPrincipal;
      },
    );
  }
}