extends Node

## Singleton (Autoload) para mantener el estado de la carrera
## al cambiar entre la UI (Simulation) y el mundo 3D (Track3D)

var simulator: RaceSimulator
## Piloto que controla el jugador
var player_driver: Driver
## Estrategia elegida por el jugador antes de la carrera
var player_strategy: Strategy

func _ready() -> void:
	# Inicializamos los pilotos para el MVP
	simulator = RaceSimulator.new()
	
	var starting_drivers: Array[Driver] = []
	starting_drivers.append(Driver.new("Carlos Sainz", 87.0))
	starting_drivers.append(Driver.new("Fernando Alonso", 92.0))
	starting_drivers.append(Driver.new("Max Verstappen", 94.0))
	starting_drivers.append(Driver.new("Lando Norris", 90.0))
	starting_drivers.append(Driver.new("Charles Leclerc", 88.0))
	starting_drivers.append(Driver.new("Lewis Hamilton", 89.0))
	
	# Guardamos los pilotos registrados en el simulador para que estén disponibles
	simulator.registered_drivers = starting_drivers
	player_driver = starting_drivers[1]
