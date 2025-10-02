extends Node3D
class_name Head

var player: Player
var mouse_capture: MouseCapture

var DEFAULT_HEIGHT: float
var crouch_offset: float
var crouch_speed: float

func _ready() -> void:

	player = get_owner()
	mouse_capture = player.mouse_capture

	DEFAULT_HEIGHT = player.DEFAULT_HEIGHT
	crouch_offset = player.crouch_offset
	crouch_speed = player.crouch_speed

var _rotation: Vector3

func _process(delta: float) -> void:
	var input = mouse_capture.consume_input()
	if input != Vector2.ZERO:
		update_camera_rotation(input)

func update_camera_rotation(input: Vector2) -> void:
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(-90), deg_to_rad(90))

	var _player_rotation = Vector3(0.0, _rotation.y, 0.0)
	var _camera_rotation = Vector3(_rotation.x, 0.0, 0.0)

	transform.basis = Basis.from_euler(_camera_rotation)
	player.update_rotation(_player_rotation)

	rotation.z = 0.0

func update_camera_height(delta: float, direction: int) -> void:
	if position.y >= crouch_offset and position.y <= DEFAULT_HEIGHT:
		position.y = clampf(position.y + (crouch_speed * direction) * delta, crouch_offset, DEFAULT_HEIGHT)
