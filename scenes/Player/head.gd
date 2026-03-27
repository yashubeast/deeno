extends Node3D
class_name Head

@export var player: Player
@export var camera: Camera3D
#var _rotation: Vector3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if not player.freelook:
		%Neck.rotation.y = lerp(%Neck.rotation.y, 0.0, delta * player.freelook_snap_back_speed)
		%Eyes.rotation.x = lerp(%Eyes.rotation.x, 0.0, delta * player.freelook_snap_back_speed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if player.freelook:
			%Neck.rotate_y(deg_to_rad(-event.relative.x * player.sensitivity))
			%Neck.rotation.y = clamp(%Neck.rotation.y, deg_to_rad(-135), deg_to_rad(135))
			%Eyes.rotate_x(deg_to_rad(-event.relative.y * player.sensitivity))
			%Eyes.rotation.x = clamp(%Eyes.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		else:
			player.rotate_y(deg_to_rad(-event.relative.x * player.sensitivity))
			rotate_x(deg_to_rad(-event.relative.y * player.sensitivity))
			rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))

#func _process(delta: float) -> void:
	#var input = mouse_capture.consume_input()
	#if input != Vector2.ZERO:
		#update_camera_rotation(input)
#
#func update_camera_rotation(input: Vector2) -> void:
	#_rotation.x += input.y
	#_rotation.y += input.x
	#_rotation.x = clamp(_rotation.x, deg_to_rad(-90), deg_to_rad(90))
#
	#var _player_rotation = Vector3(0.0, _rotation.y, 0.0)
	#var _camera_rotation = Vector3(_rotation.x, 0.0, 0.0)
#
	#transform.basis = Basis.from_euler(_camera_rotation)
	#player.update_rotation(_player_rotation)
#
	#rotation.z = 0.0

func update_camera_height(delta: float, direction: int) -> void:
	if position.y >= player.crouch_offset and position.y <= player.DEFAULT_HEIGHT:
		position.y = clampf(
			position.y + (player.crouch_speed * direction) * delta,
			player.crouch_offset,
			player.DEFAULT_HEIGHT
			)
