import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/tarea_priorizada.dart';
import 'package:flow_academic/features/ prioritization/presentation/providers/prioridades_provider.dart';
import 'package:flow_academic/features/ prioritization/presentation/widgets/tarea_priorizada_card.dart';

class ListaPrioridadesPage extends StatelessWidget {
  const ListaPrioridadesPage({
    super.key,
    required this.onNuevaTarea,
    this.titulo = 'Prioridades',
    this.acciones = const [],
  });

  final VoidCallback onNuevaTarea;
  final String titulo;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PrioridadesProvider>();
    final vacio = !p.cargando && p.error == null && p.prioridades.isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(titulo), actions: acciones),
      body: _cuerpo(context, p, vacio),
      floatingActionButton: vacio
          ? null
          : FloatingActionButton.extended(
        onPressed: onNuevaTarea,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }

  Widget _cuerpo(BuildContext context, PrioridadesProvider p, bool vacio) {
    if (p.cargando) return const Center(child: CircularProgressIndicator());
    if (p.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(p.error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (vacio) return _Vacio(onNuevaTarea: onNuevaTarea);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: p.prioridades.length,
      itemBuilder: (context, i) {
        final item = p.prioridades[i];
        return TareaPriorizadaCard(
          key: ValueKey(item.tarea.id),
          item: item,
          onCompletar: () => _completar(context, p, item),
        );
      },
    );
  }

  Future<void> _completar(
      BuildContext context, PrioridadesProvider p, TareaPriorizada item) async {
    final mensajero = ScaffoldMessenger.of(context);
    try {
      await p.completar(item.tarea.id);
      mensajero.showSnackBar(
        SnackBar(content: Text('Tarea completada: "${item.tarea.titulo}".')),
      );
    } catch (_) {
      mensajero.showSnackBar(
        const SnackBar(
            content: Text('No se pudo completar la tarea. Intenta de nuevo.')),
      );
    }
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.onNuevaTarea});
  final VoidCallback onNuevaTarea;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.task_alt, size: 64),
            const SizedBox(height: 16),
            Text('No tienes tareas pendientes',
                style: tema.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Cuando registres una tarea, aquí verás cuál atender primero.',
                style: tema.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onNuevaTarea,
              child: const Text('Nueva tarea'),
            ),
          ],
        ),
      ),
    );
  }
}