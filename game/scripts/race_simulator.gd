extends RefCounted
class_name RaceSimulator

## Instancia de la carrera actual
var current_race: Race
## Lista de todos los pilotos registrados en el juego/temporada
var registered_drivers: Array[Driver] = []
## Tiempo base por vuelta en segundos (ej. 1 minuto y 30 segundos)
var base_lap_time: float = 90.0

## Inicializa una nueva carrera con los pilotos dados
func start_new_race(race_name: String, total_laps: int, drivers: Array[Driver]) -> void:
	current_race = Race.new(race_name, total_laps, drivers)

## Simula la carrera completa recorriendo todas las vueltas matemáticamente (Solo para testeo sin 3D)
func simulate_full_race() -> void:
	if not current_race: return
	for i in range(current_race.total_laps): 
		simulate_lap()

## Simula una sola vuelta para todos los pilotos
func simulate_lap() -> void:
	if not current_race: return
	
	current_race.current_lap += 1
	for state in current_race.driver_states:
		var lap_time = calculate_lap_time(state)
		state.last_lap_time = lap_time
		state.total_time += lap_time
		state.current_lap += 1

## Calcula el tiempo de vuelta de un piloto basado en su habilidad, su neumático y un factor aleatorio
func calculate_lap_time(state: DriverState) -> float:
	var random_factor = randf_range(0.9, 1.1)
	var lap_time = base_lap_time - (state.driver.skill * 0.1 * random_factor)
	if state.current_tyre:
		#El agarre resta tiempo; la goma gastada lo suma (0,05s por cada 1% gastado)
		lap_time -= state.current_tyre.grip_bonus
		lap_time += (100.0 - state.tyre_wear) * 0.05
	# A mayor habilidad, se resta más tiempo (el piloto es más rápido)
	return lap_time

## Devuelve el DriverState de un piloto en concreto
func get_driver_state(driver: Driver) -> DriverState:
	if not current_race: return null
	for state in current_race.driver_states:
		if state.driver == driver:
			return state
	return null
