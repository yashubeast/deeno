extends Camera3D
class_name Camera

@export var player: Player

@onready var toggle_camera_tilt := player.toggle_camera_tilt
@onready var toggle_fall_kick := player.toggle_fall_kick
@onready var toggle_damage_kick := player.toggle_damage_kick
@onready var toggle_weapon_kick := player.toggle_weapon_kick
@onready var toggle_screen_shake := player.toggle_screen_shake
@onready var toggle_headbob := player.toggle_headbob
@onready var toggle_camera_zoom := player.toggle_camera_zoom

@onready var run_pitch := player.run_pitch
@onready var max_pitch := player.max_pitch
@onready var run_roll := player.run_roll
@onready var max_roll := player.max_roll

@onready var fall_time := player.fall_time

@onready var damage_time := player.damage_time

@onready var weapon_decay := player.weapon_decay

@onready var bob_pitch := player.bob_pitch
@onready var bob_roll := player.bob_roll
@onready var bob_up := player.bob_up
@onready var bob_frequency := player.bob_frequency

@onready var camera_zoom_max := player.camera_zoom_max
@onready var camera_zoom_speed := player.camera_zoom_speed

var _fall_value := 0.0
var _fall_timer := 0.0

var _damage_pitch := 0.0
var _damage_roll := 0.0
var _damage_timer := 0.0

var _weapon_kick_angles := Vector3.ZERO

var _screen_shake_tween: Tween

var _step_timer := 0.0

const MIN_SCREEN_SHAKE := 0.05
const MAX_SCREEN_SHAKE := 0.5

var _current_camera_zoom := 0.0 # 0 -> first person, 1 -> fully zoomed out

var debug_camera_rotation: Vector3
var debug_camera_position: Vector3

################################################################################

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_out"):
		_current_camera_zoom = clamp(_current_camera_zoom + camera_zoom_speed, 0.0, camera_zoom_max)
	elif event.is_action_pressed("zoom_in"):
		_current_camera_zoom = clamp(_current_camera_zoom - camera_zoom_speed, 0.0, camera_zoom_max)

func _process(delta: float) -> void:
	_calculate_view_offset(delta)

func _calculate_view_offset(delta: float) -> void:
	_fall_timer -= delta
	_damage_timer -= delta

	#var velocity = player.velocity
	#var speed = Vector2(velocity.x, velocity.z).length()
	var angles := Vector3.ZERO
	var offset := Vector3.ZERO

	#_update_step_timer(delta, speed)
	#var bob_sin = sin(_step_timer * 2.0 * PI) * 0.5

	#if toggle_camera_tilt: angles = _apply_tilt(velocity, angles)
	#if toggle_fall_kick: offset = _apply_fall_kick(angles, offset)
	#if toggle_damage_kick: angles = _apply_damage_kick(angles)
	#if toggle_weapon_kick: angles = _apply_weapon_kick(delta, angles)
	#if toggle_headbob: angles = _apply_headbob(bob_sin, speed, angles, offset)
	if toggle_camera_zoom: offset = _apply_zoom(delta, offset)

	position = offset
	rotation = angles
	debug_camera_rotation = angles
	debug_camera_position = offset
	

#func _update_step_timer(delta: float, speed: float) -> void:
	#if speed > 0.1 and player.is_on_floor():
		#_step_timer = fmod(_step_timer + delta * (speed / bob_frequency), 1.0)
	#else:
		#_step_timer = 0.0

#func _apply_tilt(velocity: Vector3, angles: Vector3) -> Vector3:
	#var forward = global_transform.basis.z
	#var right = global_transform.basis.x
	#angles.x += clampf(velocity.dot(forward) * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
	#angles.z -= clampf(velocity.dot(right) * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
	#return angles
#
#func _apply_fall_kick(angles: Vector3, offset: Vector3) -> Vector3:
	#var fall_kick = max(0.0, _fall_timer / fall_time) * _fall_value
	#angles.x -= fall_kick
	#offset.y -= fall_kick
	#return offset
#
#func _apply_damage_kick(angles: Vector3) -> Vector3:
	#var ratio = max(0.0, _damage_timer / damage_time)
	#angles.x += ratio * _damage_pitch
	#angles.z += ratio * _damage_roll
	#return angles
#
#func _apply_weapon_kick(delta: float, angles: Vector3) -> Vector3:
	#_weapon_kick_angles = _weapon_kick_angles.move_toward(Vector3.ZERO, weapon_decay * delta)
	#angles += _weapon_kick_angles
	#return angles
#
#func _apply_headbob(bob_sin: float, speed: float, angles: Vector3, _offset: Vector3) -> Vector3:
	#angles.x -= bob_sin * deg_to_rad(bob_pitch) * speed
	#angles.z -= bob_sin * deg_to_rad(bob_roll) * speed
	#return angles

func _apply_zoom(delta: float, offset: Vector3) -> Vector3:
	offset.z += _current_camera_zoom
	return offset

# public #######################################################################
#func add_fall_kick(fall_strength: float) -> void:
	#_fall_value = deg_to_rad(fall_strength)
	#_fall_timer = fall_time
#
#func add_damage_kick(pitch: float, roll: float, source: Vector3) -> void:
	#var forward = global_transform.basis.z
	#var right = global_transform.basis.x
	#var direction = global_position.direction_to(source)
	#_damage_pitch = deg_to_rad(pitch) * direction.dot(forward)
	#_damage_roll = deg_to_rad(roll) * direction.dot(right)
	#_damage_timer = damage_time
#
#func add_weapon_kick(pitch: float, yaw: float, roll: float) -> void:
	#_weapon_kick_angles.x += deg_to_rad(pitch)
	#_weapon_kick_angles.y += deg_to_rad(randf_range(-yaw, yaw))
	#_weapon_kick_angles.z += deg_to_rad(randf_range(-roll, roll))
#
#func add_screen_shake(amount: float, seconds: float) -> void:
	#if _screen_shake_tween:
		#_screen_shake_tween.kill()
	#_screen_shake_tween = create_tween()
	#_screen_shake_tween.tween_method(
		#_update_screen_shake.bind(amount), 0.0, 1.0, seconds
	#).set_ease(Tween.EASE_OUT)
#
#func _update_screen_shake(alpha: float, amount: float) -> void:
	#var shake = remap(amount, 0.0, 1.0, MIN_SCREEN_SHAKE, MAX_SCREEN_SHAKE) * (1.0 - alpha)
	#h_offset = randf_range(-shake, shake)
	#v_offset = randf_range(-shake, shake)
