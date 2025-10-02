extends State

func _on_sprinting_state_physics_processing(delta: float) -> void:

	if not Input.is_action_pressed("sprint") or not player.input_dir.y < 0:

		player.state_chart.send_event("onStanding")

	if Input.is_action_pressed("crouch"):

		if not player.is_on_floor(): return

		if player.input_dir.y < 0:
			player.state_chart.send_event("onSliding")
		else:
			player.state_chart.send_event("onCrouching")

	player.head.update_camera_height(delta, 1)

func _on_sprinting_state_entered() -> void:

	player.sprinting_modifier = player.sprinting_speed
	player.stand()

func _on_sprinting_state_exited() -> void:

	player.sprinting_modifier = 0.0
