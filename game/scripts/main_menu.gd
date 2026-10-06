extends Control

## Este script maneja la lógica de la escena de inicio (MainMenu).
## Contiene un botón que al pulsarlo carga la escena de destino.

func _ready():
	$StartButton.pressed.connect(_on_start_button_pressed)

## Función que se ejecuta cuando se presiona el botón "Start Game".
## Cambia la escena a "simulation.tscn".
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://game/scenes/simulation.tscn")
