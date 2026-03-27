extends Node3D
class_name Weapon

@onready var player: Player = owner
var components := {}

var ammo: Node
var hitscan: Node
var ads: Node

func _ready() -> void:
	var cmps = get_node_or_null("Cmps")
	if cmps:
		for child in cmps.get_children():
			components[child.get_script()] = child
	
	ammo = get_cmp(CmpAmmo)
	hitscan = get_cmp(CmpHitscan)
	ads = get_cmp(CmpAds)

func get_cmp(script) -> Node:
	return components.get(script, null)

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("shoot"):
		if ammo and not ammo.can_shoot(): return
		if hitscan: hitscan.shoot(player)
		if ammo: ammo.consume()
	
	if Input.is_action_just_pressed("reload"):
		if ammo: ammo.reload()
	
	if ads:
		if Input.is_action_pressed("ads"): ads.enter()
		if Input.is_action_just_released("ads"): ads.exit()
