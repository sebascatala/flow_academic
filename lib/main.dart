import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

import 'features/academic/data/repositories/firestore_materia_repository.dart';
import 'features/academic/data/repositories/firestore_tarea_repository.dart';
import 'features/academic/domain/entities/materia.dart';
import 'features/academic/domain/repositories/materia_repository.dart';
import 'features/academic/domain/repositories/tarea_repository.dart';
import 'features/academic/presentation/pages/tarea_form_page.dart';
import 'features/academic/presentation/providers/materias_provider.dart';
import 'features/academic/presentation/providers/tareas_provider.dart';
import 'features/ prioritization/presentation/pages/lista_prioridades_page.dart';
import 'features/ prioritization/presentation/providers/prioridades_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: FirebaseAuthRepository()),
        ),
        Provider<MateriaRepository>(create: (_) => FirestoreMateriaRepository()),
        Provider<TareaRepository>(create: (_) => FirestoreTareaRepository()),
      ],
      child: MaterialApp(
        title: 'Flow Academic',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const AuthGate(paginaPrincipal: _Sesion()),
      ),
    );
  }
}

/// Crea los providers de datos para el usuario con sesión iniciada.
/// Crea los providers de datos para el usuario con sesión iniciada.
class _Sesion extends StatelessWidget {
  const _Sesion();

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    if (usuario == null) return const SizedBox.shrink();

    return MultiProvider(
      key: ValueKey(usuario.id),
      providers: [
        ChangeNotifierProvider(
          create: (c) => MateriasProvider(
              repositorio: c.read<MateriaRepository>(), usuarioId: usuario.id),
        ),
        ChangeNotifierProvider(
          create: (c) => TareasProvider(
              repositorio: c.read<TareaRepository>(), usuarioId: usuario.id),
        ),
        ChangeNotifierProvider(
          create: (c) => PrioridadesProvider(
            tareaRepositorio: c.read<TareaRepository>(),
            materiaRepositorio: c.read<MateriaRepository>(),
            usuarioId: usuario.id,
          ),
        ),
      ],
      child: const _Inicio(),
    );
  }
}

class _Inicio extends StatelessWidget {
  const _Inicio();

  Future<void> _nuevaTarea(BuildContext context) async {
    final materias = context.read<MateriasProvider>().materias;
    final tareas = context.read<TareasProvider>();
    final prioridades = context.read<PrioridadesProvider>();
    final mensajero = ScaffoldMessenger.of(context);
    String? idCreada;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TareaFormPage(
          materias: materias,
          onGuardar: (t) async {
            await tareas.crear(t);
            idCreada = t.id;
          },
        ),
      ),
    );

    if (idCreada == null) return;
    final puesto = prioridades.posicionDe(idCreada!);
    if (puesto != null) {
      mensajero.showSnackBar(SnackBar(
        content: Text(
            'Tarea guardada. Quedó en el puesto $puesto de ${prioridades.prioridades.length}.'),
      ));
    }
  }

  // TEMPORAL: hasta que Ana Elena termine la pantalla de materias.
  Future<void> _cargarMateriasDePrueba(BuildContext context) async {
    final materias = context.read<MateriasProvider>();
    final mensajero = ScaffoldMessenger.of(context);
    await materias.crear(const Materia(
        id: 'cal', nombre: 'Cálculo II', codigo: 'MAT-201',
        docente: 'Docente', creditos: 5, promedio: 40));
    await materias.crear(const Materia(
        id: 'his', nombre: 'Historia', codigo: 'HUM-101',
        docente: 'Docente', creditos: 3, promedio: 90));
    mensajero.showSnackBar(
        const SnackBar(content: Text('Materias de prueba cargadas.')));
  }

  @override
  Widget build(BuildContext context) {
    return ListaPrioridadesPage(
      onNuevaTarea: () => _nuevaTarea(context),
      acciones: [
        IconButton(
          icon: const Icon(Icons.science_outlined),
          tooltip: 'Cargar materias de prueba',
          onPressed: () => _cargarMateriasDePrueba(context),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () => context.read<AuthProvider>().signOut(),
        ),
      ],
    );
  }
}
class _InicioTemporal extends StatelessWidget {
  const _InicioTemporal();

  Future<void> _cargarDatosDePrueba(BuildContext context) async {
    final materias = context.read<MateriasProvider>();
    await materias.crear(const Materia(
        id: 'cal', nombre: 'Cálculo II', codigo: 'MAT-201',
        docente: 'Docente', creditos: 5, promedio: 40));
    await materias.crear(const Materia(
        id: 'his', nombre: 'Historia', codigo: 'HUM-101',
        docente: 'Docente', creditos: 3, promedio: 90));
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final materias = context.watch<MateriasProvider>();
    final tareas = context.watch<TareasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${usuario?.nombre ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
                '${materias.materias.length} materias · ${tareas.tareas.length} tareas'),
          ),
          TextButton(
            onPressed: () => _cargarDatosDePrueba(context),
            child: const Text('Cargar materias de prueba'),
          ),
          for (final t in tareas.tareas)
            ListTile(
              title: Text(t.titulo),
              subtitle: Text('${t.materiaId} · ${t.estado.name}'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TareaFormPage(
              materias: materias.materias,
              onGuardar: tareas.crear,
            ),
          ),
        ),
      ),
    );
  }
}