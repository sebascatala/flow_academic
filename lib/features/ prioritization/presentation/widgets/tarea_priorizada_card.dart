import 'package:flutter/material.dart';
import '../../domain/entities/tarea_priorizada.dart';

String textoVencimiento(int dias) {
  if (dias == 0) return 'vence hoy';
  if (dias == 1) return 'vence mañana';
  if (dias > 1) return 'vence en $dias días';
  if (dias == -1) return 'venció ayer';
  return 'venció hace ${-dias} días';
}

class TareaPriorizadaCard extends StatelessWidget {
  const TareaPriorizadaCard({
    super.key,
    required this.item,
    required this.onCompletar,
  });

  final TareaPriorizada item;
  final VoidCallback onCompletar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final t = item.tarea;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 14, child: Text('${item.posicion}')),
                const SizedBox(width: 8),
                if (item.posicion == 1)
                  const Chip(
                    label: Text('Atender primero'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(t.titulo, style: tema.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${item.nombreMateria} · ${textoVencimiento(item.factores.diasRestantes)}',
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Dificultad ${t.dificultad}/5 · Importancia ${t.importancia}/5',
              style: tema.textTheme.bodySmall,
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              shape: const Border(),
              collapsedShape: const Border(),
              title: const Text('¿Por qué este orden?'),
              children: _explicacion(context),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCompletar,
                icon: const Icon(Icons.check),
                label: const Text('Marcar como completada'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _explicacion(BuildContext context) {
    final f = item.factores;
    final promedio = ((1 - f.rendimientoBajo) * 100).round();

    // Las claves deben coincidir con las de CalculadorPrioridad (aportes).
    final detalle = <String, String>{
      'Fecha de entrega': textoVencimiento(f.diasRestantes),
      'Importancia': '${item.tarea.importancia} de 5',
      'Dificultad': '${item.tarea.dificultad} de 5',
      'Rendimiento en la materia': 'promedio $promedio de 100',
    };

    return [
      for (final e in item.aportes.entries)
        _FilaFactor(
          nombre: e.key,
          detalle: detalle[e.key] ?? '',
          porcentaje: item.puntaje > 0 ? e.value / item.puntaje : 0,
        ),
      const SizedBox(height: 4),
      Text(
        'Orden calculado con una regla provisional.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }
}

class _FilaFactor extends StatelessWidget {
  const _FilaFactor({
    required this.nombre,
    required this.detalle,
    required this.porcentaje,
  });

  final String nombre;
  final String detalle;
  final double porcentaje;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(nombre, style: tema.bodyMedium)),
              Text('${(porcentaje * 100).round()} % del puntaje',
                  style: tema.bodySmall),
            ],
          ),
          Text(detalle, style: tema.bodySmall),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: porcentaje.clamp(0.0, 1.0).toDouble()),
        ],
      ),
    );
  }
}