extends Node
class_name CmpHealth

@export var max_health: float = 100.0
var health: float

signal health_changed(current: float, maximum: float)
signal died

func _ready() -> void:
	health = max_health

func take_damage(amount: float) -> void:
	print("ouch")
	if health <= 0: return
	health = clampf(health - amount, 0.0, max_health)
	print("hit: ", health, " / ", max_health)
	health_changed.emit(health, max_health)
	if health <= 0: die()

func die() -> void:
	print("dead")
	died.emit()
	owner.queue_free()
