extends AnimatableBody3D
class_name Car3D

@onready var mesh_instance: MeshInstance3D = $Mesh
@onready var pit_timer: Timer = $PitTimer

## Rapidez con la que el coche cambia de ritmo al entrar en un tramo (más alto = más brusco)
@export var acceleration: float = 0.5
## Factor de velocidad que lleva ahora mismo; se acerca poco a poco al del tramo
var current_factor: float = 1.0
## Indica si el coche está parado en boxes
var is_in_pit: bool = false

## Piloto asignado a este coche
var driver: Driver
## Velocidad actual del coche en metros por segundo
var current_speed: float = 0.0
## Número de vueltas completadas por este coche (-1 indica que no ha cruzado la meta de salida)
var completed_laps: int = -1
## Longitud del circuito (se asigna desde track_3d)
var track_length: float = 0.0

## Señal emitida cuando el coche completa una vuelta (pasa de progress max a 0)
signal lap_completed(car: Car3D)

## Inicializa el coche asignándole un piloto y un color distintivo
func setup(p_driver: Driver, p_color: Color) -> void:
	driver = p_driver
	
	# Creamos un material único para el color y se lo asignamos a la malla existente
	var material = StandardMaterial3D.new()
	material.albedo_color = p_color
	mesh_instance.material_override = material

## Actualiza la posición del coche en el PathFollow3D padre
func move_car(delta: float, speed_factor: float = 1.0) -> void:
	if current_speed <= 0 or is_in_pit: return
	
	var path_follow = get_parent() as PathFollow3D
	if not path_follow: return
	
	var old_progress = path_follow.progress
	current_factor = move_toward(current_factor, speed_factor, acceleration * delta)
	var distance_to_move = current_speed * current_factor * delta
	path_follow.progress += distance_to_move
	
	# Comprobar si el progreso actual es menor que el anterior (ha dado la vuelta al circuito)
	if path_follow.progress < old_progress:
		if completed_laps < 0:
			completed_laps = 0 # Pasó por meta desde la parrilla de salida
		else:
			completed_laps += 1
			lap_completed.emit(self) # ¡Emitimos la señal para el track!
	
	# Lógica para centrarse en el carril (h_offset = 0) de forma progresiva
	if path_follow.h_offset != 0.0:
		# move_toward mueve el valor actual hacia el objetivo (0.0) sin pasarse
		var drift_speed = 1.0 # metros por segundo que se desplaza lateralmente
		path_follow.h_offset = move_toward(path_follow.h_offset, 0.0, drift_speed * delta)

## Devuelve la distancia total recorrida en metros por este coche
func get_race_progress() -> float:
	var path_follow = get_parent() as PathFollow3D
	if not path_follow: return 0.0
	
	# Si estamos en la parrilla de salida (-1), restamos una vuelta de distancia
	var laps_multiplier = completed_laps
	return (laps_multiplier * track_length) + path_follow.progress

## Para el coche a un lado de la pista durante los segundos indicados
func start_pit_stop(duration: float) -> void:
	is_in_pit = true
	(get_parent() as PathFollow3D).h_offset = 1.2
	pit_timer.start(duration)

## Se llama sola cuando el PitTimer termina: el coche vuelve a pista
func _on_pit_timer_timeout() -> void:
	is_in_pit = false
