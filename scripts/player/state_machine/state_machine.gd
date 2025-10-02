extends Node

class_name StateMachine

@onready var player = get_owner() as Player

func _process(delta: float) -> void:

	if player:
		player.state_chart.set_expression_property("Speed", player.speed)
		player.state_chart.set_expression_property("HorVelocity", Vector2(player.velocity.x, player.velocity.z).length())
		player.state_chart.set_expression_property("VerVelocity", player.velocity.y)
		player.state_chart.set_expression_property("Hitting Head", player.crouch_check.is_colliding())
		player.state_chart.set_expression_property("Looking at", player.interaction_raycast.current_object)
		# player.state_chart.set_expression_property("Input dir", player.input_dir)
		# player.state_chart.set_expression_property("Desired dir", player.desired_dir)
		player.state_chart.set_expression_property("Grapple", player.grappled)
