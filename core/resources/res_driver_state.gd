extends Resource
class_name DriverState

## Referencia al piloto original
@export var driver: Driver
## Posición actual en la carrera (1º, 2º, 3º...)
@export var position: int = 0
## Vuelta en la que se encuentra actualmente
@export var current_lap: int = 0
## Tiempo que lleva corriendo en la vuelta actual (se reinicia cada vez que cruza la meta)
@export var current_lap_time: float = 0.0
## Tiempo que ha tardado en completar la última vuelta
@export var last_lap_time: float = 0.0
## Tiempo total acumulado desde que empezó la carrera
@export var total_time: float = 0.0
## Neumático que lleva montado ahora
@export var current_tyre: TyreCompound
## Goma que le queda (100 = nuevo, 0 = destrozado)
@export var tyre_wear: float = 100.0
## Estrategia que sigue el piloto en esta carrera
@export var strategy: Strategy
## Cuántas paradas lleva hechas
@export var pit_stops_done: int = 0

## Inicializa el estado del piloto para una carrera
func _init(p_driver: Driver = null) -> void:
	driver = p_driver
	position = 0
	current_lap = 0
	current_lap_time = 0.0
	last_lap_time = 0.0
	total_time = 0.0

## Devuelve la próxima parada prevista, o null si ya no le quedan
func get_next_pit_stop() -> PitStop:
	if not strategy or pit_stops_done >= strategy.pit_stops.size(): return null
	return strategy.pit_stops[pit_stops_done]
