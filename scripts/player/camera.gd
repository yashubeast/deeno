extends Camera3D
class_name Camera

var player: Player
var mouse_capture: MouseCapture

var camera_tilt
var fall_kick
var damage_kick
var weapon_kick
var screen_shake
var headbob
var camera_zoom

var run_pitch
var max_pitch
var run_roll
var max_roll

var fall_time

var damage_time

var weapon_decay

var bob_pitch
var bob_roll
var bob_up
var bob_frequency

var camera_zoom_max
var camera_zoom_speed

func _ready() -> void:

	player = get_owner()
	mouse_capture = player.mouse_capture

	camera_tilt = player.camera_tilt
	fall_kick = player.fall_kick
	damage_kick = player.damage_kick
	weapon_kick = player.weapon_kick
	screen_shake = player.screen_shake
	headbob = player.headbob
	camera_zoom = player.camera_zoom

	run_pitch = player.run_pitch
	max_pitch = player.max_pitch
	run_roll = player.run_roll
	max_roll = player.max_roll

	fall_time = player.fall_time

	damage_time = player.damage_time

	weapon_decay = player.weapon_decay

	bob_pitch = player.bob_pitch
	bob_roll = player.bob_roll
	bob_up = player.bob_up
	bob_frequency = player.bob_frequency

	camera_zoom_max = player.camera_zoom_max
	camera_zoom_speed = player.camera_zoom_speed

# private vals

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

var current_camera_zoom := 0.0 # 0 -> first person, 1 -> fully zoomed out

func _process(delta: float) -> void:
	calculate_view_offset(delta)

func calculate_view_offset(delta):

	if not player: return

	_fall_timer -= delta
	_damage_timer -= delta

	var velocity = player.velocity

	# headbob step timer and sin value
	var speed = Vector2(velocity.x, velocity.z).length()
	if speed > 0.1 and player.is_on_floor():
		_step_timer += delta * (speed / bob_frequency)
		_step_timer = fmod(_step_timer, 1.0)
	else:
		_step_timer = 0.0
	var bob_sin = sin(_step_timer * 2.0 * PI) * 0.5 # 0.5 reduces the magnitude of the sine wave, i.e. less movement

	var angles = Vector3.ZERO
	var offset = Vector3.ZERO

	# camera tilt
	if camera_tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x

		var forward_dot = velocity.dot(forward)
		var forward_tilt = clampf(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		angles.x += forward_tilt

		var right_dot = velocity.dot(right)
		var side_tilt = clampf(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
		angles.z -= side_tilt

	# fall kick
	if fall_kick:
		var fall_ratio = max(0.0, _fall_timer / fall_time)
		var fall_kick_amount = fall_ratio * _fall_value
		angles.x -= fall_kick_amount
		offset.y -= fall_kick_amount

	# damage kick
	if damage_kick:
		var damage_ratio = max(0.0, _damage_timer / damage_time)
		# damage ratio = ease(damage_ratio, -2) # if you want to ease over time
		angles.x += damage_ratio * _damage_pitch
		angles.z += damage_ratio * _damage_roll

	# weapon kick
	if weapon_kick:
		_weapon_kick_angles = _weapon_kick_angles.move_toward(Vector3.ZERO, weapon_decay * delta)
		angles += _weapon_kick_angles

	# headbob
	if headbob:
		var pitch_delta = bob_sin * deg_to_rad(bob_pitch) * speed
		angles.x -= pitch_delta

		var roll_delta = bob_sin * deg_to_rad(bob_roll) * speed
		angles.z -= roll_delta

		var bob_height = bob_sin * speed * bob_up
		offset.y += bob_height

	# camera zoom
	if mouse_capture and camera_zoom:
		var scroll = mouse_capture.consume_scroll()
		if scroll != 0:
			current_camera_zoom = clamp(
				current_camera_zoom + scroll * camera_zoom_speed * delta,
				0.0,
				camera_zoom_max
			)
		offset.z -= -current_camera_zoom

	position = offset
	rotation = angles

func add_fall_kick(fall_strength: float):
	_fall_value = deg_to_rad(fall_strength)
	_fall_timer = fall_time

func add_damage_kick(pitch: float, roll: float, source: Vector3):
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	var direction = global_position.direction_to(source)
	var forward_dot = direction.dot(forward)
	var right_dot = direction.dot(right)
	_damage_pitch = deg_to_rad(pitch) * forward_dot
	_damage_roll = deg_to_rad(roll) * right_dot
	_damage_timer = damage_time

func add_weapon_kick(pitch: float, yaw: float, roll: float):
	_weapon_kick_angles.x += deg_to_rad(pitch)
	_weapon_kick_angles.y += deg_to_rad(randf_range(-yaw, yaw))
	_weapon_kick_angles.z += deg_to_rad(randf_range(-roll, roll))

# takes a value of 0.0 to 1.0 for screen shake strength and tweens that offset on both the horizontal and vertical
# offsets of the camera over a period of seconds
func add_screen_shake(amount: float, seconds: float) -> void:
	if _screen_shake_tween:
		_screen_shake_tween.kill()

	_screen_shake_tween = create_tween()
	_screen_shake_tween.tween_method(update_screen_shake.bind(amount), 0.0, 1.0, seconds).set_ease(Tween.EASE_OUT)

func update_screen_shake(alpha: float, amount: float) -> void:
	amount = remap(amount, 0.0, 1.0, MIN_SCREEN_SHAKE, MAX_SCREEN_SHAKE)
	var current_shake_amount = amount * (1.0 - alpha)
	h_offset = randf_range(-current_shake_amount, current_shake_amount)
	v_offset = randf_range(-current_shake_amount, current_shake_amount)
