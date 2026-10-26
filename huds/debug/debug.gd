extends Control
class_name DebugHud


@onready var _panel: PanelContainer = %PanelContainer
@onready var _label: Label = %Label
## Set by Main once the player exists.
var player: CharacterBody3D = null: set = set_player
var _velocity_component: VelocityComponent = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_toggle(false)


func _toggle(open: bool) -> void:
	visible = open
	set_process(open) # No per-frame work while hidden.


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_debug"):
		_toggle(not visible)
		get_viewport().set_input_as_handled()


func set_player(value: CharacterBody3D) -> void:
	player = value
	_velocity_component = null
	var cm := ComponentManager.of(player)
	_velocity_component = cm.get_component(VelocityComponent)
	var node := player.get_node_or_null("ComponentManager/VelocityComponent")
	_velocity_component = node as VelocityComponent
	if _velocity_component == null:
		push_error("Couldn't get the velocity component frm player.")



func _process(delta: float) -> void:
	var lines := PackedStringArray()

	# Performance.
	lines.append("FPS: %d" % Engine.get_frames_per_second())
	lines.append("Frame: %.2f ms" % (delta * 1000.0))

	lines.append("")

	# Player.
	if is_instance_valid(player):
		var p := player.global_position
		var v := player.velocity
		lines.append("XYZ: %.2f / %.2f / %.2f" % [p.x, p.y, p.z])
		lines.append("Velocity: %.2f / %.2f / %.2f" % [v.x, v.y, v.z])
		lines.append("Speed: %.2f" % v.length())
		lines.append("On floor: %s" % player.is_on_floor())
	else:
		lines.append("Player not found")

	_label.text = "\n".join(lines)
	_panel.reset_size() # Let panel shrink back when text gets shorter.
