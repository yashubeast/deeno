extends Node

@export var player: Player
@export var stateChart: StateChart

var camera_lerp_state := 1

func _physics_process(delta: float) -> void:
	player.head.update_camera_height(delta, camera_lerp_state)

func _process(_delta: float) -> void:

	stateChart.set_expression_property("dir", player.dir)
	stateChart.set_expression_property("dir input", player.dir_input)
	stateChart.set_expression_property("velocity length", player.velocity.length())
	stateChart.set_expression_property("velocity", player.velocity)
	stateChart.set_expression_property("sliding timer", player.sliding_timer)
	stateChart.set_expression_property("cam rot", player.camera.debug_camera_rotation)
	stateChart.set_expression_property("cam pos", player.camera.debug_camera_position)

# idle #########################################################################

func _on_idle_state_physics_processing(_delta: float) -> void:
	if Input.is_action_pressed("crouch"): stateChart.send_event("toCrouching")
	elif player.dir.length() > 0.0:
		if Input.is_action_pressed("sprint"): stateChart.send_event("toSprinting")
		else: stateChart.send_event("toWalking")

# walking ######################################################################

func _on_walking_state_entered() -> void:
	player.speed_modifier = 0

func _on_walking_state_physics_processing(_delta: float) -> void:
	if Input.is_action_pressed("crouch"): stateChart.send_event("toCrouching")
	elif Input.is_action_pressed("sprint"): stateChart.send_event("toSprinting")
	elif player.dir.length() <= 0: stateChart.send_event("toIdle")

# sprinting ####################################################################

func _on_sprinting_state_entered() -> void:
	player.speed_modifier = player.sprinting_speed

func _on_sprinting_state_physics_processing(_delta: float) -> void:
	if Input.is_action_pressed("crouch") and player.is_on_floor(): stateChart.send_event("toSliding")
	elif not Input.is_action_pressed("sprint"): stateChart.send_event("toWalking")
	
# crouching ####################################################################

func _on_crouching_state_entered() -> void:
	player.speed_modifier = player.crouching_speed
	player.crouch()
	camera_lerp_state = -1

func _on_crouching_state_physics_processing(_delta: float) -> void:
	if not Input.is_action_pressed("crouch") and not %CrouchCheck.is_colliding():
		stateChart.send_event("toIdle")

func _on_crouching_state_exited() -> void:
	player.stand()
	camera_lerp_state = 1

# sliding ######################################################################

func _on_sliding_state_entered() -> void:
	player.speed_modifier = player.sliding_speed
	player.crouch()
	camera_lerp_state = -1
	player.sliding_timer = player.sliding_time
	player.dir_slide = player.dir
	player.is_sliding = true

func _on_sliding_state_physics_processing(delta: float) -> void:
	
	if player.sliding_timer <= 0.0:
		if Input.is_action_pressed("crouch") or %CrouchCheck.is_colliding():
			stateChart.send_event("toCrouching")
		else: stateChart.send_event("toSprinting")
		return
	
	if Input.is_action_pressed("jump"):
		if Input.is_action_pressed("sprint"): stateChart.send_event("toSprinting")
		elif Input.is_action_pressed("crouch"): stateChart.send_event("toCrouching")
		elif player.dir_input != Vector2.ZERO: stateChart.send_event("toWalking")
		else: stateChart.send_event("toIdle")
	
	player.sliding_timer -= delta

func _on_sliding_state_exited() -> void:
	player.stand()
	camera_lerp_state = 1
	player.sliding_timer = 0.0
	player.is_sliding = false
