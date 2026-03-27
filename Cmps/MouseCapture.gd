extends Node
class_name MouseCapture

@export var player: Player
var sensitivity: float
var _scroll_delta := 0.0

func _unhandled_input(event: InputEvent) -> void:

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return

	if event is not InputEventMouseButton: return
	if !event.pressed: return
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP: _scroll_delta -= 1
		MOUSE_BUTTON_WHEEL_DOWN: _scroll_delta += 1

func consume_scroll() -> float:
	var result = _scroll_delta
	_scroll_delta = 0.0
	return result
