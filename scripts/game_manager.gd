extends Node
class_name GameManager

func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_cancel"):

		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().quit()

	if event is InputEventMouseButton and event.pressed:

		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and event.button_index == MOUSE_BUTTON_LEFT:

			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
