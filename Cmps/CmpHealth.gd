extends Node
class_name CmpHealth

signal health_changed(current_health: int, max_health: int)
signal health_depleted

@export var health_max: int = 100
@export var auto_free_owner: bool = true

var is_invulnerable: bool = false
var health_current: int
var iframe_timer: float = 0.0

func _ready() -> void:
	health_current = health_max
	health_changed.emit(health_current, health_max)

func _process(delta: float) -> void:
	# count down iframe_timer
	if iframe_timer > 0.0:
		iframe_timer -= delta
		if iframe_timer <= 0.0:
			is_invulnerable = false

func take_damage(amount: int, iframe_amount: float) -> void:

	if health_current <= 0 or is_invulnerable: return

	# take damage
	health_current -= amount
	health_current = max(0, health_current)
	health_changed.emit(health_current, health_max)
	print("hit: ", health_current, " / ", health_max)

	# iframe
	if iframe_amount:
		is_invulnerable = true
		iframe_timer = iframe_amount

	# die
	if health_current <= 0:
		die()

func die() -> void:
	print("dead")
	health_depleted.emit()
	if auto_free_owner:
		owner.queue_free()
