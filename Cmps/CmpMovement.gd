extends Node
class_name CmpMovement

@export var body: CharacterBody3D

var _movement_velocity := Vector2.ZERO
var speed_modifier := 0.0

func _ready() -> void:
	pass

func processVelocity(desired_direction: Vector3) -> void:
	
	var speed = walking_speed + speed_modifier
	var accel = acceleration if body.is_on_floor() else air_acceleration
	
	_movement_velocity = Vector2(body.velocity.x, body.velocity.z)
	
	if desired_direction != Vector3.ZERO:
		_movement_velocity = _movement_velocity.lerp(
			Vector2(desired_direction.x, desired_direction.z) * speed, accel)
	elif body.is_on_floor():
		_movement_velocity = _movement_velocity.move_toward(
			Vector2.ZERO, deceleration)
	
	body.velocity.x = _movement_velocity.x
	body.velocity.z = _movement_velocity.y

func processGravity(delta: float) -> void:
	if body.is_on_floor(): return
	body.velocity -= body.get_gravity() * delta
