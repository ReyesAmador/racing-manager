extends Button
class_name DriverRow

## Rellena la fila con la posición, el piloto, su última vuelta y el estado del neumático
func update_row(pos: int, state: DriverState) -> void:
	%PosLabel.text = str(pos) + "º"
	%NameLabel.text = state.driver.name
	%TimeLabel.text = str(snapped(state.last_lap_time, 0.001)) + "s" if state.last_lap_time > 0 else "--"
	if state.current_tyre: %TyreColor.color = state.current_tyre.color
	%WearLabel.text = str(roundi(state.tyre_wear)) + "%"
