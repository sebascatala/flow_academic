import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flow_academic/features/academic/domain/entities/materia.dart';
import 'package:flow_academic/features/academic/domain/entities/tarea.dart';
import 'package:flow_academic/features/academic/data/repositories/firestore_materia_repository.dart';
import 'package:flow_academic/features/academic/data/repositories/firestore_tarea_repository.dart';
import 'package:flow_academic/features/academic/presentation/providers/tareas_provider.dart';
import 'package:flow_academic/features/academic/presentation/pages/tarea_form_page.dart';
import 'package:flow_academic/features/ prioritization/presentation/providers/prioridades_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FirebaseApp app;
  late FirebaseFirestore db;
  late FirestoreMateriaRepository materias;
  late FirestoreTareaRepository tareas;
  const his = Materia(id: 'his', nombre: 'Historia', codigo: 'H', docente: '', creditos: 3, promedio: 90);
  const cal = Materia(id: 'cal', nombre: 'Cálculo II', codigo: 'C', docente: '', creditos: 5, promedio: 40);
  const host = String.fromEnvironment('FIRESTORE_HOST', defaultValue: '10.0.2.2');
  CollectionReference<Map<String, dynamic>> col(String uid) => db.collection('usuarios').doc(uid).collection('tareas');
  Future<void> limpiar(String uid) async {
    for (final nombre in ['tareas', 'materias']) {
      final c = db.collection('usuarios').doc(uid).collection(nombre);
      for (final d in (await c.get(const GetOptions(source: Source.server))).docs) {
        await d.reference.delete();
      }
    }
  }
  setUpAll(() async {
    app = await Firebase.initializeApp(name: 'verificacion-mvp', options: const FirebaseOptions(apiKey: 'demo-key', appId: '1:1234567890:android:abcdef123456', messagingSenderId: '1234567890', projectId: 'demo-flowacademic'));
    db = FirebaseFirestore.instanceFor(app: app);
    db.settings = const Settings(persistenceEnabled: false);
    db.useFirestoreEmulator(host, 8080);
    materias = FirestoreMateriaRepository(firestore: db);
    tareas = FirestoreTareaRepository(firestore: db);
  });
  Future<void> esperar(WidgetTester tester, bool Function() condicion) async {
    for (var i = 0; i < 150; i++) {
      if (condicion()) return;
      await tester.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    fail('No se observó la condición dentro del plazo');
  }
  Tarea tarea(String id, String materia, int dias, int nivel) => Tarea(id: id, materiaId: materia, titulo: 'Tarea $id', fechaEntrega: DateTime.now().add(Duration(days: dias)), dificultad: nivel, importancia: nivel);
  testWidgets('I-01 CA-06 CA-07: escritura real y reordenamiento reactivo', (tester) async {
    const uid = 'mvp-i01';
    await limpiar(uid);
    addTearDown(() => limpiar(uid));
    await materias.crear(uid, his);
    await materias.crear(uid, cal);
    final tp = TareasProvider(repositorio: tareas, usuarioId: uid);
    final pp = PrioridadesProvider(tareaRepositorio: tareas, materiaRepositorio: materias, usuarioId: uid);
    addTearDown(tp.dispose);
    addTearDown(pp.dispose);
    await tp.crear(tarea('A', 'his', 2, 1));
    await esperar(tester, () => !pp.cargando && pp.posicionDe('A') == 1);
    final b = tarea('B', 'cal', 5, 5);
    await tp.crear(b);
    await esperar(tester, () => pp.posicionDe('B') == 1 && pp.posicionDe('A') == 2);
    final docs = await col(uid).get(const GetOptions(source: Source.server));
    expect(docs.docs.map((d) => d.id), unorderedEquals(['A', 'B']));
    final guardada = docs.docs.singleWhere((d) => d.id == 'B').data();
    expect(guardada['materiaId'], 'cal');
    expect(guardada['titulo'], b.titulo);
    expect(guardada['dificultad'], 5);
    expect(guardada['importancia'], 5);
    expect(guardada['estado'], 'pendiente');
    expect((guardada['fechaEntrega'] as Timestamp).millisecondsSinceEpoch, b.fechaEntrega.millisecondsSinceEpoch);
    expect(pp.error, isNull);
  });
  Future<void> formulario(WidgetTester tester, TareasProvider tp, {required bool dificultad}) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (context) => TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => TareaFormPage(materias: const [his], onGuardar: tp.crear))), child: const Text('Abrir'))))));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Tarea ficticia');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<Materia>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historia').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elige una fecha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    if (dificultad) {
      await tester.ensureVisible(find.byType(DropdownButtonFormField<int>).first);
      await tester.tap(find.byType(DropdownButtonFormField<int>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nivel 3').last);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.byType(DropdownButtonFormField<int>).last);
    await tester.tap(find.byType(DropdownButtonFormField<int>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nivel 4').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar tarea'));
    await tester.tap(find.text('Guardar tarea'));
    await tester.pump();
  }
  testWidgets('I-02 CA-03: rechazo del formulario y persistencia intacta', (tester) async {
    const uid = 'mvp-i02';
    await limpiar(uid);
    addTearDown(() => limpiar(uid));
    await materias.crear(uid, his);
    await tareas.crear(uid, tarea('A', 'his', 2, 1));
    final antes = (await col(uid).get(const GetOptions(source: Source.server))).docs.single;
    final tp = TareasProvider(repositorio: tareas, usuarioId: uid);
    addTearDown(tp.dispose);
    await formulario(tester, tp, dificultad: false);
    await tester.pumpAndSettle();
    expect(find.text('Elige una dificultad del 1 al 5.'), findsOneWidget);
    expect(find.text('Tarea ficticia'), findsOneWidget);
    final despues = (await col(uid).get(const GetOptions(source: Source.server))).docs.single;
    expect(despues.id, antes.id);
    expect(despues.data(), equals(antes.data()));
  });
  testWidgets('F-01: escritura denegada, sin falso éxito', (tester) async {
    const uid = 'mvp-f01';
    expect((await col(uid).get(const GetOptions(source: Source.server))).docs, isEmpty);
    final tp = TareasProvider(repositorio: tareas, usuarioId: uid);
    addTearDown(tp.dispose);
    await formulario(tester, tp, dificultad: true);
    const error = 'No se pudo guardar la tarea. Revisa tu conexión e intenta de nuevo.';
    await esperar(tester, () => find.text(error).evaluate().isNotEmpty);
    expect(find.text('Nueva tarea'), findsOneWidget);
    expect(find.text('Tarea ficticia'), findsOneWidget);
    expect((await col(uid).get(const GetOptions(source: Source.server))).docs, isEmpty);
  });
}
