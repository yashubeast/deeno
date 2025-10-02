
extends Area3D

@export var boost_up := 0.0
@export var boost_forward := 200000.0

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		var up = Vector3.UP * boost_up
		var forward = -body.global_transform.basis.z.normalized() * boost_forward
		body.velocity = up + forward
