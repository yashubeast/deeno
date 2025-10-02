extends State

func _on_standing_state_physics_processing(delta: float) -> void:

	if Input.is_action_pressed("crouch"):

		if player.is_on_floor():

			player.state_chart.send_event("onCrouching")

	elif Input.is_action_pressed("sprint") and player.input_dir.y < 0:

		player.state_chart.send_event("onSprinting")

	player.head.update_camera_height(delta, 1)

func _on_standing_state_entered() -> void:

	player.stand()
