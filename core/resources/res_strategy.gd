extends Resource
class_name Strategy

## Nombre para moistrar (ej. "1 parada B-D")
@export var strategy_name: String = "Estrategia"
## Neumático con el que empieza el piloto
@export var starting_tyre: TyreCompound
## Paradas previstas, en orden
@export var pit_stops: Array[PitStop] = []
