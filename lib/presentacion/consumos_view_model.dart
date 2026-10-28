import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:ecotrack_meta/dominio/meta.dart';
import 'package:flutter/foundation.dart';

class ConsumosViewModel extends ChangeNotifier {
  ConsumosViewModel(this.repositorio);

  final ConsumoRepository repositorio;

  List<Consumo> consumos = [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  double get total {
    double suma = 0;
    for (final c in consumos) {
      suma += c.litros;
    }
    return suma;
  }

  double get avance => avanceDeMeta(total: total, meta: meta);

  bool get metaSuperada => total > meta;

  Future<void> cargar() async {
    consumos = await repositorio.todos();
    notifyListeners();
  }

  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    String texto = litrosTexto.trim();
    texto = texto.replaceAll(',', '.');
    double? litros;
    try {
      litros = double.parse(texto);
    } catch (e) {
      litros = null;
    }

    final errorValidacion = validarLitros(litros);
    if (errorValidacion != null) {
      error = errorValidacion;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    await repositorio.guardar(Consumo(laboratorio: laboratorio, litros: litros!));
    consumos = await repositorio.todos();
    guardando = false;
    notifyListeners();
    return true;
  }

  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}
