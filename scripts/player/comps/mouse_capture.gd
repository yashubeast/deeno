extends Node
class_name MouseCapture

var player: Player
var sensitivity: float

func _ready() -> void:

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	player = get_owner()
	sensitivity = player.sensitivity

var _mouse_input: Vector2
var _scroll_delta := 0.0

func _unhandled_input(event: InputEvent) -> void:

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return

	if event is InputEventMouseMotion:
		_mouse_input.x += -event.screen_relative.x * sensitivity
		_mouse_input.y += -event.screen_relative.y * sensitivity

	if event is InputEventMouseButton:

		if !event.pressed: return

		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_scroll_delta -= 1
			MOUSE_BUTTON_WHEEL_DOWN:
				_scroll_delta += 1

func consume_scroll() -> float:
	var result = _scroll_delta
	_scroll_delta = 0.0
	return result

func consume_input() -> Vector2:
	var result = _mouse_input
	_mouse_input = Vector2.ZERO
	return result
