extends Node
class_name Main
## Main entrypoint for the game.


# World roots.
@onready var level_root : Node3D   = %LevelRoot
@onready var entity_root: Node3D   = %EntityRoot
@onready var debug_hud  : DebugHud = %DebugHud
const PLAYER_SCENE_UID := "uid://bekm0kiclx1ue"
# Levels.
const DEBUG_LEVEL_SCENE_UID := "uid://ch6vdo8f7lmnf"
var player: CharacterBody3D  = null # TODO: change to Entity or Player
var _current_level: Level    = null


func _ready() -> void:
	_init_player()
	load_level(DEBUG_LEVEL_SCENE_UID)
	pass


func _init_player() -> void:
	var player_scene: PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return

	player = player_scene.instantiate() as CharacterBody3D
	if player == null:
		push_error("Loaded player scene does not instantiate properly: " + PLAYER_SCENE_UID)
		return

	entity_root.add_child(player)
	debug_hud.player = player


# TODO: accept only Level class
## Called for loading a level scene.
func load_level(level_scene: String) -> void:
	# Call during idle time.
	_deferred_load_level.call_deferred(level_scene)

func _deferred_load_level(level_scene_uid: String) -> void:
	if is_instance_valid(_current_level):
		_current_level.queue_free()
		_current_level = null
		# Wait to allow the queued deletion to process so it is out of the scene tree.
		await get_tree().process_frame
	

	var new_level_packed := ResourceLoader.load(level_scene_uid, "PackedScene") as PackedScene
	if new_level_packed == null:
		push_error("Could not load level as a packed scene: " + level_scene_uid)
		return

	var new_level := new_level_packed.instantiate()
	if not new_level:
		push_error("Could not instantiate new level: " + level_scene_uid)
		return

	if not new_level is Level:
		new_level.free()
		push_error("Loaded level is not of type Level: " + level_scene_uid)
		return

	_current_level = new_level as Level
	level_root.add_child(_current_level)

	_place_player_at_level_spawn()


## Places the player at the default spawn location of the level.
func _place_player_at_level_spawn() -> void:
	if player == null:
		push_error("Cannot place player in level because it is null.")
		return
	if _current_level == null:
		push_error("Cannot place player into level because level is null.")
		return

	player.velocity = Vector3.ZERO
	player.global_position = _current_level.get_default_player_spawn()
