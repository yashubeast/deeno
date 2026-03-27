extends Control
class_name Reticle

@export var my_size: float = 1.0
@export var gap: float = 0.0
@export var thickness: float = 4.0
@export var color: Color = Color.RED

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var center = get_viewport_rect().size / 2
	# left
	draw_rect(Rect2(center + Vector2(-gap - my_size, -thickness / 2), Vector2(my_size, thickness)), color)
	# right
	draw_rect(Rect2(center + Vector2(gap, -thickness / 2), Vector2(my_size, thickness)), color)
	# up
	draw_rect(Rect2(center + Vector2(-thickness / 2, -gap - my_size), Vector2(thickness, my_size)), color)
	# down
	draw_rect(Rect2(center + Vector2(-thickness / 2, gap), Vector2(thickness, my_size)), color)
