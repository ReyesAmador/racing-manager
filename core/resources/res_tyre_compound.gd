extends Resource
class_name TyreCompound

## Nombre del compuesto
@export var compound_name: String = "Medio"

## Color para mostrarlo en la interfaz
@export var color: Color = Color.YELLOW

## Segundos que gana por vuelta (más alto = más rápido)
@export var grip_bonus: float = 0.0

## Porcentaje de goma que pierde cada vuelta
@export var wear_per_lap: float = 5.0
