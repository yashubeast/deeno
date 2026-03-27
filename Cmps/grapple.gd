extends Node

var player: Player
var raycast: RayCast3D
var rest_length: float
var stiffness: float
var damping: float
var grappled: bool

# private vars
var target: Vector3

func _ready() -> void:

	player = get_owner()
	raycast = player.grapple_raycast
	rest_length = player.grapple_rest_length
	stiffness = player.grapple_stiffness
	damping = player.grapple_damping
	grappled = player.grappled

func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("grapple"):

		if grappled: # ungrapple
			ungrapple()
		else: # grapple
			grapple()

	handle_grapple(delta)

func grapple():

	if raycast.is_colliding():

		target = raycast.get_collision_point()
		grappled = true

func ungrapple():

	grappled = false

func handle_grapple(delta):

	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)

	var displacement = target_dist - rest_length

	var force = Vector3.ZERO

	if displacement >0:

		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude

		var vel_dot = player.velocity.dot(target_dir)
		var damping = -damping * vel_dot * target_dir

		force = spring_force + damping

	player.velocity += force * delta
