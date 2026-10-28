import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:flutter/material.dart';

class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    super.key,
    required this.alGuardar,
    required this.error,
    required this.guardando,
  });

  final Future<bool> Function(String laboratorio, String litros) alGuardar;
  final String? error;
  final bool guardando;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  String _laboratorioSeleccionado = laboratoriosUtez.first;
  final TextEditingController _litrosController = TextEditingController();

  @override
  void dispose() {
    _litrosController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final ok = await widget.alGuardar(_laboratorioSeleccionado, _litrosController.text);
    if (!mounted) return;
    if (ok) {
      _litrosController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consumo guardado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _laboratorioSeleccionado,
            items: laboratoriosUtez
                .map((lab) => DropdownMenuItem<String>(
                      value: lab,
                      child: Text(lab),
                    ))
                .toList(),
            onChanged: widget.guardando
                ? null
                : (valor) {
                    if (valor != null) {
                      setState(() {
                        _laboratorioSeleccionado = valor;
                      });
                    }
                  },
            decoration: const InputDecoration(labelText: 'Laboratorio'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('litros'),
            controller: _litrosController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Litros',
              errorText: widget.error,
            ),
            enabled: !widget.guardando,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.guardando ? null : _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class ListaHistorial extends StatelessWidget {
  const ListaHistorial({super.key, required this.consumos, required this.total});

  final List<Consumo> consumos;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (consumos.isEmpty) {
      return const Center(child: Text('Sin consumos'));
    }

    return ListView(
      children: [
        ListTile(
          title: Text('Total: ${total.toStringAsFixed(1)} L'),
        ),
        const Divider(),
        for (final c in consumos)
          ListTile(
            title: Text(c.laboratorio),
            trailing: Text('${c.litros.toStringAsFixed(1)} L'),
          ),
      ],
    );
  }
}

class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.usado,
    required this.meta,
    required this.avance,
    required this.superada,
    required this.alSubir,
    required this.alBajar,
  });

  final double usado;
  final double meta;
  final double avance;
  final bool superada;
  final VoidCallback alSubir;
  final VoidCallback alBajar;

  @override
  Widget build(BuildContext context) {
    final porcentaje = avance.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Usado: ${usado.toStringAsFixed(1)} de ${meta.toStringAsFixed(1)} L'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: porcentaje),
          const SizedBox(height: 12),
          Text(superada ? 'Te pasaste de la meta' : 'Dentro de la meta'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                key: const Key('bajarMeta'),
                onPressed: alBajar,
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                key: const Key('subirMeta'),
                onPressed: alSubir,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PantallasEcoTrack extends StatefulWidget {
  const PantallasEcoTrack({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });

  final String titulo;
  final Widget registro;
  final Widget historial;
  final Widget meta;

  @override
  State<PantallasEcoTrack> createState() => _PantallasEcoTrackState();
}

class _PantallasEcoTrackState extends State<PantallasEcoTrack> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final paginas = [widget.registro, widget.historial, widget.meta];
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: IndexedStack(
        index: _indice,
        children: paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: (i) {
          setState(() {
            _indice = i;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Registro'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Meta'),
        ],
      ),
    );
  }
}
