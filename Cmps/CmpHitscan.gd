extends Node
class_name CmpHitscan

@export var damage := 25.0
@export var my_range := 100.0

func shoot(player: Player) -> void:
	
	print("hitscan: shoot()")
	player.raycastWeapon.force_raycast_update()
	if player.raycastWeapon.is_colliding():
		var hit = player.raycastWeapon.get_collider()
		var cmpHealth = get_health_component(hit)
		#var point = player.raycastWeapon.get_collision_point()
		if cmpHealth:
			print("hitscan: shoot() if cmpHealth")
			cmpHealth.take_damage(damage)
		#player.camera.add_weapon_kick(1.0, 0.5, 0.3)

func get_health_component(node: Node) -> CmpHealth:
	if node is CmpHealth: return node
	for child in node.get_children():
		var result = get_health_component(child)
		if result: return result
	return null
