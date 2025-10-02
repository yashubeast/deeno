extends Node
class_name State

var player: Player

func _ready() -> void:

	if %StateMachine and %StateMachine is StateMachine:
		player = get_owner() as Player
