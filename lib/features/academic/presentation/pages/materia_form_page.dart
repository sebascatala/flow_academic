import 'package:flutter/material.dart';
import '../../domain/entities/materia.dart';
import 'package:flow_academic/features/academic/domain/validadores_materia.dart';

class MateriaFormPage extends StatefulWidget {
  const MateriaFormPage({super.key, required this.onGuardar});

  final Future<void> Function(Materia materia) onGuardar;

  @override
  State<MateriaFormPage> createState() => _MateriaFormPageState();
}

class _MateriaFormPageState extends State<MateriaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _codigo = TextEditingController();
  final _docente = TextEditingController();
  final _creditos = TextEditingController();
  final _promedio = TextEditingController();
  bool _guardando = false;
  String? _errorGuardado;

  @override
  void dispose() {
    _nombre.dispose();
    _codigo.dispose();
    _docente.dispose();
    _creditos.dispose();
    _promedio.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _errorGuardado = null;
    });

    final materia = Materia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombre.text.trim(),
      codigo: _codigo.text.trim(),
      docente: _docente.text.trim(),
      creditos: int.tryParse(_creditos.text.trim()) ?? 0,
      // 70 = valor neutro, el mismo que usa Materia por defecto
      promedio: double.tryParse(_promedio.text.trim().replaceAll(',', '.')) ?? 70,
    );

    try {
      await widget.onGuardar(materia);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGuardado =
      'No se pudo guardar la materia. Revisa tu conexión e intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva materia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(
                    labelText: 'Nombre de la materia', border: OutlineInputBorder()),
                validator: ValidadoresMateria.nombre,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigo,
                decoration: const InputDecoration(
                    labelText: 'Código (opcional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _docente,
                decoration: const InputDecoration(
                    labelText: 'Docente (opcional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditos,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Créditos (opcional)', border: OutlineInputBorder()),
                validator: ValidadoresMateria.creditos,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _promedio,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Promedio actual, 0 a 100 (opcional)',
                  helperText: 'Si lo dejas vacío se usa 70 como valor neutro.',
                  border: OutlineInputBorder(),
                ),
                validator: ValidadoresMateria.promedio,
              ),
              if (_errorGuardado != null) ...[
                const SizedBox(height: 12),
                Text(_errorGuardado!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Guardar materia'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}