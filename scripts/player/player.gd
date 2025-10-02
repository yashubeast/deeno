extends CharacterBody3D
class_name Player

@export_group("References")
@export var standing_collision: CollisionShape3D
@export var standing_mesh: MeshInstance3D
@export var crouching_collision: CollisionShape3D
@export var crouching_mesh: MeshInstance3D
@export var crouch_check: ShapeCast3D
@export var head: Head
@export var camera: Camera3D
@export var interaction_raycast: InteractionRaycast
@export var grapple_raycast: RayCast3D
# components
@export var mouse_capture: MouseCapture
# state
@export var state_chart: StateChart
@export var state_machine: StateMachine

@export_group("Movement")
@export var walking_speed := 5.0
@export var sprinting_speed := 2.0
@export var sliding_speed := 2.0
@export var crouching_speed := -3.0
@export var acceleration := 0.2
@export var air_acceleration := 0.03
@export var deceleration := 0.5
@export var jump_velocity := 5.0

@export_group("Grapple")
@export var grapple_rest_length := 2.0
@export var grapple_stiffness := 10.0
@export var grapple_damping := 1.0

@export_group("Posture Change")
@export var DEFAULT_HEIGHT := 0.5 # inspector > transform > position > y value of head relative to player
@export var crouch_offset := 0.1 # crouch y level destination from DEFAULT_HEIGHT
@export var crouch_speed := 5.0

@export_category("Camera Effects")
@export var sensitivity := 0.003
@export_group("Effects Toggle")
@export var camera_tilt := true
@export var fall_kick := true
@export var damage_kick := true
@export var weapon_kick := true
@export var screen_shake := true
@export var headbob := true
@export var camera_zoom := true
@export_group("Fall Kick")
@export var fall_time := 0.3
@export var fall_velocity_threshold := -5.0
@export_group("Damage Kick")
@export var damage_time := 0.3
@export_group("Weapon Kick")
@export var weapon_decay := 0.5
@export_group("Camera Tilt")
@export var run_pitch := 0.1
@export var max_pitch := 1.0
@export var run_roll := 0.25
@export var max_roll := 2.5
@export_group("Headbob")
@export_range(0.0, 0.1, 0.001) var bob_pitch := 0.05
@export_range(0.0, 0.1, 0.001) var bob_roll := 0.025
@export_range(0.0, 0.04, 0.001) var bob_up := 0.005
@export_range(3.0, 8.0, 0.1) var bob_frequency := 6.0
@export_group("Camera Zoom")
@export var camera_zoom_max := 20.0
@export var camera_zoom_speed := 20.0

var input_dir := Vector2.ZERO
var desired_dir
var _movement_velocity := Vector2.ZERO
var speed := 0.0
var sprinting_modifier := 0.0
var sliding_modifier := 0.0
var crouching_modifier := 0.0
var current_fall_velocity: float
var slide_dir := Vector3.ZERO
var is_sliding := false
var grappled := false

func _physics_process(delta: float) -> void:

	# apply gravity
	if not is_on_floor(): velocity += get_gravity() * delta

	# speed modifier
	var speed_modifier = sprinting_modifier + crouching_modifier + sliding_modifier
	speed = walking_speed + speed_modifier

	# input
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	desired_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# determine horizontal velocity vector
	var current_horizontal = Vector2(_movement_velocity.x, _movement_velocity.y)
	var accel = acceleration if is_on_floor() else air_acceleration

	if is_sliding:
		desired_dir = Vector3(slide_dir.x, 0, slide_dir.z).normalized()
		current_horizontal = lerp(current_horizontal, Vector2(desired_dir.x, desired_dir.z) * speed, accel)
	elif input_dir != Vector2.ZERO:
		current_horizontal = lerp(current_horizontal, Vector2(desired_dir.x, desired_dir.z) * speed, accel)
	elif is_on_floor():
		# on ground
		current_horizontal = current_horizontal.move_toward(Vector2.ZERO, deceleration)

	_movement_velocity = Vector2(current_horizontal.x, current_horizontal.y)
	velocity.x = _movement_velocity.x
	velocity.z = _movement_velocity.y

	move_and_slide()

func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

func check_fall_speed() -> bool:
	if current_fall_velocity < fall_velocity_threshold:
		current_fall_velocity = 0.0
		return true
	else:
		current_fall_velocity = 0.0
		return false

func stand() -> void:
	standing_collision.disabled = false
	standing_mesh.visible = true
	crouching_collision.disabled = true
	crouching_mesh.visible = false

func crouch() -> void:
	standing_collision.disabled = true
	standing_mesh.visible = false
	crouching_collision.disabled = false
	crouching_mesh.visible = true
