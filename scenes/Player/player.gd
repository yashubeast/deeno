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
@export var raycastWeapon: RayCast3D
@export var hook_controller: HookController

@export_group("Movement")
@export var walking_speed := 5.0
@export var sprinting_speed := 2.0
@export var crouching_speed := -3.0
@export var sliding_speed := 3.0
@export var sliding_time := 1.0
@export var swinging_speed := 10.0
#
@export var jump_velocity := 5.0
@export var gravity_modifier := 1.3
@export var acceleration := 10.0
@export var deceleration := 8.0

@export var control_ground := 1.0
@export var control_slow := 0.05
@export var control_medium := 0.15
@export var control_fast := 0.25
@export var control_slow_speed := 15.0
@export var control_medium_speed := 20.0
@export_group("Grapple")
@export var grapple_rest_length := 2.0
@export var grapple_stiffness := 10.0
@export var grapple_damping := 1.0

@export_group("Posture Change")
@export var DEFAULT_HEIGHT := 0.5 # inspector > transform > position > y value of head relative to player
@export var crouch_offset := 0.1 # crouch y level destination from DEFAULT_HEIGHT
@export var crouch_speed := 5.0

@export_category("Camera Effects")
@export var sensitivity := 0.15
@export_group("Effects Toggle")
@export var toggle_camera_tilt := true
@export var toggle_fall_kick := true
@export var toggle_damage_kick := true
@export var toggle_weapon_kick := true
@export var toggle_screen_shake := true
@export var toggle_headbob := true
@export var toggle_camera_zoom := true
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
@export_group("Freelook")
@export var freelook_snap_back_speed := 10.0

var speed_modifier: float
var speed_modifier_swinging: float
var current_fall_velocity: float
var slide_dir := Vector3.ZERO
var is_sliding := false
var grappled := false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var dir := Vector3.ZERO
var dir_input := Vector2.ZERO
var dir_slide := Vector3.ZERO
var freelook := false
var sliding_timer := 0.0
#var _movement_velocity := Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	var speed = walking_speed + speed_modifier + speed_modifier_swinging
	var control: float
	
	# input
	dir_input = Input.get_vector("left", "right", "forward", "backward")
	dir = (transform.basis * Vector3(dir_input.x, 0, dir_input.y)).normalized()

	# decide control
	if is_on_floor():
		control = control_ground
	elif velocity.length() < control_slow_speed:
		control = control_slow
	elif velocity.length() < control_medium_speed:
		control = control_medium
	else:
		control = control_fast

	# decide speed_modifier_swinging
	if hook_controller.is_hook_launched and !is_on_floor():
		speed_modifier_swinging = swinging_speed
	else: speed_modifier_swinging = 0.0
	
	# fixed dir if sliding
	if is_sliding: dir = dir_slide
	
	if dir_input.length() != 0 or is_sliding:
		velocity.x = lerpf(velocity.x, dir.x * speed, acceleration * control * delta)
		velocity.z = lerpf(velocity.z, dir.z * speed, acceleration * control * delta)
	else:
		velocity.x = lerpf(velocity.x, 0, deceleration * control * delta)
		velocity.z = lerpf(velocity.z, 0, deceleration * control * delta)

	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta * gravity_modifier
	# jump
	elif Input.is_action_pressed("jump") and not hook_controller.is_hook_launched:
		velocity.y = jump_velocity

	move_and_slide()

func _process(_delta: float) -> void:
	
	freelook = Input.is_action_pressed("freelook")

#func update_rotation(rotation_input) -> void:
	#global_transform.basis = Basis.from_euler(rotation_input)

#func check_fall_speed() -> bool:
	#if current_fall_velocity < fall_velocity_threshold:
		#current_fall_velocity = 0.0
		#return true
	#else:
		#current_fall_velocity = 0.0
		#return false

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
