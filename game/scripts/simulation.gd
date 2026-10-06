extends Control

@onready var back_button = $BackButton
@onready var simulate_button = $SimulateButton
@onready var results_text = $ResultsText

## Estrategias que el jugador puede elegir antes de la carrera
@export var strategies: Array[Strategy] = []

## Configura la UI inicial
func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	if simulate_button: simulate_button.pressed.connect(_on_simulate_button_pressed)
	
	# Llenamos el desplegable con el nombre de cada estrategia
	for s in strategies: %StrategyOption.add_item(s.strategy_name)
	if strategies.size() > 0: RaceManager.player_strategy = strategies[0]
	_display_results()

## Cambia a la escena 3D de la pista. El RaceManager mantiene los datos de los pilotos.
func _on_simulate_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/track_3d.tscn")

## Muestra los resultados ordenados en el cuadro de texto, o un mensaje si aún no hay
func _display_results() -> void:
	var current_race = RaceManager.simulator.current_race
	if not current_race: return
	
	# Comprobar si ya se ha corrido la carrera revisando si alguien tiene tiempo
	var has_results = false
	for state in current_race.driver_states:
		if state.total_time > 0.0:
			has_results = true
			break
			
	if not has_results:
		if results_text: results_text.text = "Aún no hay resultados.\nPresiona 'Simular Carrera' para ir a la pista."
		return

	var sorted_states = current_race.get_standings()
	var text_content = "Resultados de " + current_race.race_name + " (" + str(current_race.total_laps) + " Vueltas):\n\n"
	
	for state in sorted_states:
		var time_str = str(snapped(state.total_time, 0.001))
		text_content += str(state.position) + ". " + state.driver.name + " - Tiempo: " + time_str + "s\n"
		
	if results_text: results_text.text = text_content

## Cambia la escena de nuevo a "main_menu.tscn"
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scenes/main_menu.tscn")


func _on_strategy_option_item_selected(index: int) -> void:
	RaceManager.player_strategy = strategies[index]
