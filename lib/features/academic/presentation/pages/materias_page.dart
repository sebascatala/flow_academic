import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/materias_provider.dart';
import 'materia_form_page.dart';

class MateriasPage extends StatelessWidget {
  const MateriasPage({super.key});

  void _nueva(BuildContext context) {
    final provider = context.read<MateriasProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MateriaFormPage(onGuardar: provider.crear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MateriasProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis materias')),
      body: _cuerpo(context, p),
      floatingActionButton: p.materias.isEmpty
          ? null
          : FloatingActionButton.extended(
        onPressed: () => _nueva(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva materia'),
      ),
    );
  }

  Widget _cuerpo(BuildContext context, MateriasProvider p) {
    if (p.cargando) return const Center(child: CircularProgressIndicator());

    if (p.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(p.error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (p.materias.isEmpty) {
      final tema = Theme.of(context).textTheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_outlined, size: 64),
              const SizedBox(height: 16),
              Text('Aún no tienes materias',
                  style: tema.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Registra tus materias para poder crear tareas.',
                  style: tema.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _nueva(context),
                child: const Text('Nueva materia'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: p.materias.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final m = p.materias[i];
        final detalle = [
          if (m.codigo.isNotEmpty) m.codigo,
          if (m.docente.isNotEmpty) m.docente,
          'Promedio ${m.promedio.round()}',
        ].join(' · ');
        return ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: Text(m.nombre),
          subtitle: Text(detalle),
        );
      },
    );
  }
}