extends State

func _on_ascending_state_physics_processing(delta: float) -> void:

	if player.velocity.y > 0.0:
		return

	player.state_chart.send_event("onDescending")
