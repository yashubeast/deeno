extends State

var slide_time := 1.5
var _slide_timer := 0.0

func _on_sliding_state_physics_processing(delta: float) -> void:

	_slide_timer -= delta

	if _slide_timer <= 0.0:

		if Input.is_action_pressed("crouch") or player.crouch_check.is_colliding():
			player.state_chart.send_event("onCrouching")
		elif Input.is_action_pressed("sprint"):
			player.state_chart.send_event("onSprinting")
		else:
			player.state_chart.send_event("onStanding")

	player.head.update_camera_height(delta, -1)

func _on_sliding_state_entered() -> void:

	player.sprinting_modifier = player.sprinting_speed
	player.sliding_modifier = player.sliding_speed

	player.is_sliding = true

	player.crouch()

	_slide_timer = slide_time

	# player.slide_dir = -player.global_transform.basis.z.normalized() # get player node's facing dir
	if player.velocity.length() > 0.1:
		player.slide_dir = player.velocity.normalized() # get player node's moving direction

func _on_sliding_state_exited() -> void:

	player.sprinting_modifier = 0.0
	player.sliding_modifier = 0.0

	player.is_sliding = false
