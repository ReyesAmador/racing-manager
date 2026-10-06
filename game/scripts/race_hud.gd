extends Control

signal driver_selected(car: Car3D)
## Escena que se usa como fila de cada piloto
@export var driver_row_scene: PackedScene

@onready var drivers_list = $VBoxContainer/DriversList
@onready var lap_label = $VBoxContainer/LapLabel

# Diccionario para no tener que recrear botones cada frame, solo reordenarlos
var car_buttons: Dictionary = {}

## Recibe la lista de coches activos y crea un botón por cada uno inicialmente
func setup_hud(active_cars: Array[Car3D]) -> void:
	for child in drivers_list.get_children():
		child.queue_free()
	car_buttons.clear()
		
	# Creamos un botón para cada coche y lo guardamos
	for car in active_cars:
		var btn = driver_row_scene.instantiate()
		btn.pressed.connect(func(): driver_selected.emit(car))
		drivers_list.add_child(btn)
		car_buttons[car] = btn

## Actualiza la lista en tiempo real
func update_hud_realtime(active_cars: Array[Car3D], current_lap: int, total_laps: int) -> void:
	if lap_label:
		lap_label.text = "Vuelta: " + str(current_lap) + " / " + str(total_laps)
		
	# Creamos una copia para no alterar el array original del track
	var sorted_cars = active_cars.duplicate()
	
	# Ordenar basándonos en la distancia total matemática recorrida por cada coche
	sorted_cars.sort_custom(func(a: Car3D, b: Car3D): return a.get_race_progress() > b.get_race_progress())
	
	# Reposicionar y actualizar texto de cada botón
	for i in range(sorted_cars.size()):
		var car = sorted_cars[i]
		var row = car_buttons.get(car) as DriverRow
		
		if row:
			row.update_row(i + 1, RaceManager.simulator.get_driver_state(car.driver))
			drivers_list.move_child(row, i)
