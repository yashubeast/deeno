extends State

func _on_laying_state_physics_processing(delta: float) -> void:

	player.head.update_camera_height(delta, -1)
