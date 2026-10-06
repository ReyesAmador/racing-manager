extends Camera3D

## Distancia mínima de zoom permitida
@export var min_zoom: float = 5.0
## Distancia máxima de zoom permitida
@export var max_zoom: float = 100.0
## Velocidad de acercamiento/alejamiento
@export var zoom_speed: float = 5.0
## Velocidad a la que se orbita la cámara con el ratón
@export var rotation_speed: float = 0.005
## Velocidad con la que la cámara persigue al coche objetivo (Lerp)
@export var follow_speed: float = 10.0

## El coche al que estamos siguiendo
var target_car: Node3D = null
## Distancia actual (Zoom)
var current_zoom: float = 40.0

## Ángulos esféricos para orbitar (Yaw = Izq/Der, Pitch = Arriba/Abajo)
var orbit_yaw: float = 0.0
var orbit_pitch: float = -PI / 4.0 # Empieza mirando hacia abajo 45 grados

## Posición actual del foco de la cámara (persigue al target_car)
var target_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	make_current()
	
	# Asegurar que el zoom inicial respete los límites que pongas en el editor
	current_zoom = clamp(current_zoom, min_zoom, max_zoom)
	
	# Ajustar posición inicial para que no empiece desde el suelo
	if is_instance_valid(target_car):
		target_position = target_car.global_position
	orbit_pitch = -deg_to_rad(45.0)

## Detecta las entradas del ratón (rueda para zoom, clic derecho arrastrado para rotar)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Zoom in / out
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_zoom -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_zoom += zoom_speed
			
		# Limitamos el zoom entre los valores exportados
		current_zoom = clamp(current_zoom, min_zoom, max_zoom)
		
	elif event is InputEventMouseMotion:
		# Solo orbitamos si se mantiene pulsado el clic derecho
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			orbit_yaw -= event.relative.x * rotation_speed
			orbit_pitch -= event.relative.y * rotation_speed
			
			# Limitamos el pitch para no dar la vuelta por debajo del suelo ni pasar por encima
			orbit_pitch = clamp(orbit_pitch, -PI / 2.0 + 0.1, -0.1)

## Mueve y orienta la cámara en cada frame
func _process(delta: float) -> void:
	if is_instance_valid(target_car):
		# Suaviza el movimiento hacia el coche para un seguimiento fluido
		target_position = target_position.lerp(target_car.global_position, follow_speed * delta)
		
	# Calcula la nueva rotación de la cámara
	var new_basis = Basis.from_euler(Vector3(orbit_pitch, orbit_yaw, 0))
	global_transform.basis = new_basis
	
	# Coloca la cámara a "current_zoom" de distancia en su propio eje Z (hacia atrás)
	global_position = target_position + new_basis.z * current_zoom
