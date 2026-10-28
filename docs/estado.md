# Gestión de estado — EcoTrack Meta

**Equipo:** Elias Manuel Marquez Bailon  
**Fecha:** 27/10/2026

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero | `_indice` en `PantallasEcoTrack` (`lib/presentacion/vistas.dart`) |
| Texto del campo de litros | Efímero | `TextEditingController` en `_FormularioRegistroState` (`lib/presentacion/vistas.dart`) |
| consumos y meta | Compartido | `ConsumosViewModel` (`lib/presentacion/consumos_view_model.dart`), con `notifyListeners()` para notificar cambios |
| total y metaSuperada | Derivado | Getters `total`, `avance`, `metaSuperada` en `ConsumosViewModel` (calculados desde `consumos` y `meta`) |
| Lo que regresa todos() | Persistido (en memoria) | `MemoriaConsumoRepository` guarda en `_consumos` y devuelve `List.unmodifiable(...)` (`lib/datos/memoria_consumo_repository.dart`) |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | Mismo `ConsumosViewModel` creado en `State` de `AppChangeNotifier` y pasado por constructor a `RegistroCN`, `HistorialCN`, `MetaCN` (`lib/variantes/a_change_notifier.dart`) | Mismo `ConsumosViewModel` colgado con `ChangeNotifierProvider` en `AppProvider`, accedido desde el árbol con `context.watch/read` (`lib/variantes/b_provider.dart`) |
| Capas | Vistas tontas reciben datos/callbacks; `ConsumosViewModel` usa contrato `ConsumoRepository`; dominio puro sin Flutter. Respeta flechas legales (`lib/presentacion/vistas.dart` no importa ViewModel/provider/datos) | Igual arquitectura en capas, sin tocar `consumos_view_model.dart` ni `vistas.dart`. Solo cambia el cableado |
| Encaje con el diagrama | `AppChangeNotifier` (Stateful) crea VM en `initState`, lo libera en `dispose()`, adapta con `ListenableBuilder` | `AppProvider` (Stateless) crea VM en `create` de `ChangeNotifierProvider` y lo carga; adaptadores sin constructor piden al árbol |
| Constructores que reciben vm | 3 (`RegistroCN(vm: ...)`, `HistorialCN(vm: ...)`, `MetaCN(vm: ...)`) | 0 (adaptadores `RegistroProvider`, `HistorialProvider`, `MetaProvider` sin parámetros) |
| Quién libera el ViewModel | `AppChangeNotifierState.dispose()` llama `vm.dispose()` (`lib/variantes/a_change_notifier.dart`) | `ChangeNotifierProvider` lo libera automáticamente al desmontar el árbol (no lo hace el desarrollador) |
| Costo de adoptarla ahora | Más explícito (control manual de creación/disposición/constructor), mayor boilerplate | Más conciso (sin pasar vm por constructor), pero depende de `context` y del árbol de widgets |
| Sustitución de la fuente de datos | Cambiando `repositorio` que se pasa a `AppChangeNotifier` (p. ej. otro `ConsumoRepository`) sin tocar vistas/ViewModel | Cambiando `repositorio` que se pasa a `AppProvider` (p. ej. otro `ConsumoRepository`) sin tocar vistas/ViewModel. Se demuestra con `RepositorioEspia` en tests |

## Elección

Elegimos: **B · provider** para el `main.dart` por menor acoplamiento (adaptadores sin constructor) y menos pasamanos.  
Se mantiene esta pieza del diagrama: **El `ConsumosViewModel` con sus reglas derivadas y `notifyListeners()`** como único dueño del estado compartido.  
Esta pieza es la que podría sustituirse después: **`ConsumoRepository`** (contrato abstracto) — podemos cambiar `MemoriaConsumoRepository` por otra implementación sin tocar dominio/presentación/vistas.
