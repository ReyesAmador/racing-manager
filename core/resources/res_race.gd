extends Resource
class_name Race

## Nombre del circuito o Gran Premio
@export var race_name: String = "Gran Premio"
## Número total de vueltas que tiene la carrera
@export var total_laps: int = 5
## Vuelta en la que se encuentra el líder de la carrera
@export var current_lap: int = 0
## Lista de los pilotos participantes y su estado en tiempo real
@export var driver_states: Array[DriverState] = []

## Crea una carrera nueva y genera los estados iniciales de los pilotos
func _init(p_name: String = "Gran Premio", p_laps: int = 5, drivers: Array[Driver] = []) -> void:
	race_name = p_name
	total_laps = p_laps
	current_lap = 0
	
	# Crea un DriverState para cada piloto que participa
	driver_states.clear()
	for d in drivers:
		var state = DriverState.new(d)
		driver_states.append(state)

## Devuelve la lista de estados ordenada por posición actual (menor tiempo total primero)
func get_standings() -> Array[DriverState]:
	var sorted_states = driver_states.duplicate()
	
	# Ordenamos por quien lleva más vueltas y, a igual vueltas, menos tiempo total
	sorted_states.sort_custom(func(a: DriverState, b: DriverState):
		if a.current_lap != b.current_lap:
			return a.current_lap > b.current_lap
		return a.total_time < b.total_time
	)
	
	# Actualizamos la posición interna de cada piloto
	for i in range(sorted_states.size()):
		sorted_states[i].position = i + 1
		
	return sorted_states
