extends Resource
class_name Driver

## Nombre del piloto
@export var name: String = "Piloto Desconocido"
## Habilidad general del piloto (afecta al tiempo por vuelta)
@export var skill: float = 50.0

## Inicializa un nuevo piloto con su nombre y habilidad
func _init(p_name: String = "Piloto", p_skill: float = 50.0) -> void:
	name = p_name
	skill = p_skill
