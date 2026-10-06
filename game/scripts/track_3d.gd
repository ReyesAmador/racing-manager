extends Node3D

@export_category("Race Configuration")
## Nombre de este circuito
@export var circuit_name: String = "Gran Premio de Godot"
## Número total de vueltas de la carrera
@export var total_laps: int = 5
## Tiempo base (en segundos) estimado por vuelta para este circuito
@export var base_lap_time: float = 90.0
## Segundos que pierde un coche en boxes
@export var pit_stop_time: float = 20.0
## % de goma por debajo del cual el piloto entra en boxes
@export var pit_wear_threshold: float = 40.0
## Estrategias disponibles; se reparten entre los pilotos por turnos
@export var strategies: Array[Strategy] = []

const CAR_SCENE = preload("res://game/scenes/car_3d.tscn")

@onready var cars_container = $CarsContainer
@onready var track_layout = $TrackLayout
@onready var camera = $Camera3D
@onready var race_hud = $RaceHUD

var driver_colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.ORANGE, Color.PURPLE, Color.CYAN, Color.MAGENTA]
var track_length: float = 0.0
## Tramos ordenados por distancia desde la salida: x = metro donde empieza, y = factor de velocidad
var sector_data: Array[Vector2] = []
## Longitud "equivalente" de la vuelta: los tramos lentos cuentan más y los rápidos menos
var effective_length: float = 0.0

# Estado de la carrera en tiempo real
var is_racing: bool = false
var active_cars: Array[Car3D] = []
var cars_finished: int = 0

func _ready() -> void:
	# Actualizar el tiempo base del simulador según la configuración de este circuito
	RaceManager.simulator.base_lap_time = base_lap_time
	
	# Inicializamos la carrera en el simulador usando los parámetros del inspector
	var drivers = RaceManager.simulator.registered_drivers
	RaceManager.simulator.start_new_race(circuit_name, total_laps, drivers)
	
	var states = RaceManager.simulator.current_race.driver_states
	for i in range(states.size()):
		states[i].strategy = strategies[i % strategies.size()]
		if states[i].driver == RaceManager.player_driver and RaceManager.player_strategy:
			states[i].strategy = RaceManager.player_strategy
		states[i].current_tyre = states[i].strategy.starting_tyre
	
	setup_grid_on_path(drivers)
	
	# Por defecto, la cámara sigue al primer coche de la parrilla
	if active_cars.size() > 0:
		camera.target_car = active_cars[0]
		
	# Inicializamos el HUD que ya está en la escena
	if race_hud:
		race_hud.setup_hud(active_cars)
		race_hud.driver_selected.connect(_on_hud_driver_selected)
	
	# Iniciar carrera después de la cuenta regresiva visual (3s)
	start_race_sequence()

func _physics_process(delta: float) -> void:
	if not is_racing: return
	
	var race = RaceManager.simulator.current_race
	var leader_lap = 1 # Para actualizar el HUD
	
	for car in active_cars:
		if car.current_speed <= 0: continue
			
		# Añadir tiempo al piloto en el nuevo DriverState
		var state = RaceManager.simulator.get_driver_state(car.driver)
		if state:
			state.total_time += delta
			state.current_lap_time += delta
		
		# Movemos el coche por la pista
		car.move_car(delta, get_speed_factor((car.get_parent() as PathFollow3D).progress))
		
		# Comprobamos en qué vuelta está para sacar la vuelta del líder
		if car.completed_laps + 1 > leader_lap:
			leader_lap = car.completed_laps + 1
			
	# Limitamos la vuelta del líder para que no ponga "Vuelta 6/5" al terminar
	if leader_lap > total_laps: leader_lap = total_laps
	
	# Actualizamos la UI en tiempo real
	if race_hud:
		race_hud.update_hud_realtime(active_cars, leader_lap, total_laps)

## Detecta matemáticamente cuando un coche completa la vuelta
func _on_car_lap_completed(car: Car3D) -> void:
	print(car.driver.name + " ha completado " + str(car.completed_laps) + " vueltas")
	
	# Actualizamos el estado en la clase Race
	var state = RaceManager.simulator.get_driver_state(car.driver)
	if state:
		state.current_lap = car.completed_laps
		# Guardamos el tiempo que tardó en hacer la vuelta y reseteamos el cronómetro
		state.last_lap_time = state.current_lap_time
		state.current_lap_time = 0.0
		state.tyre_wear = max(state.tyre_wear - state.current_tyre.wear_per_lap, 0.0)
		# Si la goma baja del límite yu no es la última vuelta, entra a boxes
		# Si toca parada según la estrategia, entra con el neumático previsto
		var next_stop = state.get_next_pit_stop()
		if next_stop and car.completed_laps == next_stop.lap:
			state.pit_stops_done += 1
			_do_pit_stop(car, state, next_stop.tyre)
		# Si no, pero la goma está al límite, parada de emergencia con el mismo compuesto
		elif state.tyre_wear < pit_wear_threshold and car.completed_laps < total_laps:
			_do_pit_stop(car, state, state.current_tyre)
		var new_lap_time = RaceManager.simulator.calculate_lap_time(state)
		car.current_speed = effective_length / new_lap_time
		
	# Comprobar si ha terminado la carrera
	if car.completed_laps >= total_laps:
		car.current_speed = 0.0 # Detener el coche
		cars_finished += 1
		_check_race_finished()

## Busca el Path3D de la pista e instancia los coches usándolo como guía
func setup_grid_on_path(drivers: Array[Driver]) -> void:
	var path_3d: Path3D = null
	for child in track_layout.get_children():
		if child is Path3D:
			path_3d = child
			break
			
	if not path_3d: return
		
	track_length = path_3d.curve.get_baked_length()
	setup_sectors(path_3d)
		
	for child in cars_container.get_children():
		child.queue_free()
		
	var shuffled_drivers = drivers.duplicate()
	shuffled_drivers.shuffle()
	active_cars.clear()
	
	for i in range(shuffled_drivers.size()):
		var path_follow = PathFollow3D.new()
		path_follow.loop = true 
		# Esto asegura que el movimiento en process actualice las físicas para el Area3D
		path_follow.use_model_front = true
		path_3d.add_child(path_follow)
		
		var car = CAR_SCENE.instantiate() as Car3D
		path_follow.add_child(car)
		
		var color = driver_colors[i % driver_colors.size()]
		car.setup(shuffled_drivers[i], color)
		car.track_length = track_length
		# Conectamos la señal matemática del coche al circuito
		car.lap_completed.connect(_on_car_lap_completed)
		active_cars.append(car)
		
		# --- Lógica de Posicionamiento en Parrilla ---
		var col = i % 2
		var row = i / 2
		
		var spacing_z = 1.0 # Metros de distancia entre filas
		var stagger = 0.5  # Desfase
		
		path_follow.h_offset = -0.4 if col == 0 else 0.4
		
		var distance_from_pole = (row * spacing_z) + (col * stagger)
		path_follow.progress = track_length - distance_from_pole
		
		car.position = Vector3(0, 0.1, 0)
		
		# Precálculo de la velocidad objetivo del coche
		# En lugar de saltar el tiempo como en el MVP, convertimos la fórmula de tiempo a Velocidad (m/s)
		# V = Espacio / Tiempo. Tiempo estimado = RaceSimulator.calculate_lap_time()
		var estimated_lap_time = RaceManager.simulator.calculate_lap_time(RaceManager.simulator.get_driver_state(car.driver))
		var speed_m_s = effective_length / estimated_lap_time
		car.current_speed = speed_m_s

## Secuencia de inicio de la carrera
func start_race_sequence() -> void:
	print("Semáforos en rojo...")
	await get_tree().create_timer(3.0).timeout
	print("¡Luces apagadas! Comienza la carrera.")
	is_racing = true

## Comprueba si todos los coches han terminado
func _check_race_finished() -> void:
	if cars_finished >= active_cars.size():
		is_racing = false
		print("¡Carrera finalizada! Volviendo a resultados...")
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://game/scenes/simulation.tscn")

## Cambia el objetivo de la cámara cuando el jugador hace clic en un botón del HUD
func _on_hud_driver_selected(car: Car3D) -> void:
	if is_instance_valid(camera):
		camera.target_car = car

## Mete el coche en boxes y le monta el neumático indicado
func _do_pit_stop(car: Car3D, state: DriverState, tyre: TyreCompound) -> void:
	state.current_tyre = tyre
	state.tyre_wear = 100.0
	car.start_pit_stop(pit_stop_time)

## Calcula dónde empieza cada tramo y la longitud equivalente de la vuelta
func setup_sectors(path_3d: Path3D) -> void:
	sector_data.clear()
	for sector in $TrackLayout/Sectors.get_children():
		# Buscamos el punto de la pista más cercano a cada marcador
		if sector is TrackSector: sector_data.append(Vector2(path_3d.curve.get_closest_offset(path_3d.to_local(sector.global_position)), sector.speed_factor))
	sector_data.sort_custom(func(a, b): return a.x < b.x)
	if sector_data.is_empty():
		effective_length = track_length
		return
	# Cada tramo "cuesta" su longitud dividida entre su factor
	effective_length = sector_data[0].x / sector_data[-1].y # De la salida al primer marcador seguimos en el último tramo
	for i in range(sector_data.size()):
		var end = sector_data[i + 1].x if i + 1 < sector_data.size() else track_length
		effective_length += (end - sector_data[i].x) / sector_data[i].y

## Devuelve el factor de velocidad del tramo en el que está esa distancia de la pista
func get_speed_factor(progress: float) -> float:
	if sector_data.is_empty(): return 1.0
	var factor = sector_data[-1].y
	for s in sector_data: if progress >= s.x: factor = s.y
	return factor
