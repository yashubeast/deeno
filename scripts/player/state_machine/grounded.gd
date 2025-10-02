extends State

func _on_grounded_state_physics_processing(delta: float) -> void:

	if not player.is_on_floor():
		player.state_chart.send_event("onAirborne")

	if Input.is_action_pressed("jump"):

		player.velocity.y += player.jump_velocity

		player.state_chart.send_event("onAirborne")
