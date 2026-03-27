extends Node
class_name CmpAmmo

@export var max_ammo: int = 30
@export var reserve_ammo: int = 90
@export var reload_time: float = 2.0

var current_ammo: int
var is_reloading := false

func _ready() -> void:
	current_ammo = max_ammo

func can_shoot() -> bool:
	return current_ammo > 0 and not is_reloading

func consume() -> void:
	current_ammo -= 1

func reload() -> void:
	if is_reloading or current_ammo == max_ammo or reserve_ammo == 0: return
	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	var needed = max_ammo - current_ammo
	var taken = min(needed, reserve_ammo)
	current_ammo += taken
	reserve_ammo -= taken
	is_reloading = false
