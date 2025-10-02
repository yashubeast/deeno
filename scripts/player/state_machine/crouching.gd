extends State

func _on_crouching_state_physics_processing(delta: float) -> void:

	if not Input.is_action_pressed("crouch") and not player.crouch_check.is_colliding():
		player.state_chart.send_event("onStanding")

	player.head.update_camera_height(delta, -1)

func _on_crouching_state_entered() -> void:

	player.crouching_modifier = player.crouching_speed

	player.crouch()

func _on_crouching_state_exited() -> void:

	player.crouching_modifier = 0.0
