import 'package:flutter/material.dart';
import '../../domain/entities/materia.dart';
import '../../domain/entities/tarea.dart';
import '../../domain/validadores_tarea.dart';

class TareaFormPage extends StatefulWidget {
  const TareaFormPage({super.key, required this.materias, required this.onGuardar});

  final List<Materia> materias;
  final Future<void> Function(Tarea tarea) onGuardar;

  @override
  State<TareaFormPage> createState() => _TareaFormPageState();
}

class _TareaFormPageState extends State<TareaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _porcentajeCtrl = TextEditingController();

  Materia? _materia;
  int? _dificultad; // sin valor inicial: así CA-03 puede ocurrir
  DateTime? _fechaEntrega;
  bool _guardando = false;
  String? _errorGuardado;
  int? _importancia; // sin valor inicial, igual que la dificultad

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _porcentajeCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha(FormFieldState<DateTime> campo) async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega ?? hoy.add(const Duration(days: 1)),
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: DateTime(hoy.year + 2),
    );
    if (elegida != null) {
      setState(() => _fechaEntrega = elegida);
      campo.didChange(elegida);
    }
  }

  String _textoFecha(DateTime f) {
    final hoy = DateTime.now();
    final dias = DateTime(f.year, f.month, f.day)
        .difference(DateTime(hoy.year, hoy.month, hoy.day))
        .inDays;
    final fecha =
        '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
    final cuando = dias == 0
        ? 'vence hoy'
        : dias == 1
        ? 'vence mañana'
        : 'vence en $dias días';
    return '$fecha · $cuando';
  }

  Future<void> _guardar() async {
    // Si algo es inválido, se muestran los mensajes y NO se guarda nada (CA-03)
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _errorGuardado = null;
    });

    final tarea = Tarea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      materiaId: _materia!.id,
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      fechaEntrega: _fechaEntrega!,
      dificultad: _dificultad!,
      importancia: _importancia!,
    );

    try {
      await widget.onGuardar(tarea);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorGuardado =
      'No se pudo guardar la tarea. Revisa tu conexión e intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sinMaterias = widget.materias.isEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (sinMaterias)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Primero registra una materia para poder crear tareas.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                    labelText: 'Título de la tarea', border: OutlineInputBorder()),
                validator: ValidadoresTarea.titulo,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Materia>(
                value: _materia,
                decoration: const InputDecoration(
                    labelText: 'Materia', border: OutlineInputBorder()),
                items: widget.materias
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.nombre)))
                    .toList(),
                onChanged: (m) => setState(() => _materia = m),
                validator: ValidadoresTarea.materia,
              ),
              const SizedBox(height: 16),
              FormField<DateTime>(
                validator: (valor) => ValidadoresTarea.fecha(valor),
                builder: (campo) => InkWell(
                  onTap: () => _elegirFecha(campo),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de entrega',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                      errorText: campo.errorText,
                    ),
                    child: Text(_fechaEntrega == null
                        ? 'Elige una fecha'
                        : _textoFecha(_fechaEntrega!)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _dificultad,
                hint: const Text('Elige una dificultad'),
                decoration: const InputDecoration(
                    labelText: 'Dificultad (1 a 5)', border: OutlineInputBorder()),
                items: [1, 2, 3, 4, 5]
                    .map((d) => DropdownMenuItem(value: d, child: Text('Nivel $d')))
                    .toList(),
                onChanged: (v) => setState(() => _dificultad = v),
                validator: ValidadoresTarea.dificultad,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _importancia,
                hint: const Text('Elige una importancia'),
                decoration: const InputDecoration(
                    labelText: 'Importancia (1 a 5)', border: OutlineInputBorder()),
                items: [1, 2, 3, 4, 5]
                    .map((i) => DropdownMenuItem(value: i, child: Text('Nivel $i')))
                    .toList(),
                onChanged: (v) => setState(() => _importancia = v),
                validator: ValidadoresTarea.importancia,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              if (_errorGuardado != null) ...[
                const SizedBox(height: 12),
                Text(_errorGuardado!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: (_guardando || sinMaterias) ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Guardar tarea'),
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