extends CharacterBody3D

# nodes
@onready var neck: Node3D = $neck
@onready var head: Node3D = $neck/head
@onready var eyes: Node3D = $neck/head/eyes
@onready var camera: Camera3D = $neck/head/eyes/camera
@onready var standing_collision: CollisionShape3D = $standing_collision
@onready var crouching_collision: CollisionShape3D = $crouching_collision
@onready var raycast: RayCast3D = $raycast

# speed vars
@export_group("speed")
var current_speed := 5.0
@export var walking_speed := 5.0
@export var sprinting_speed := 8.0
@export var crouching_speed := 3.0
@export var jump_velocity := 4.5
# slide vars
@export_group("slide")
@export var slide_speed := 10.0
var slide_timer := 0.0
@export var slide_timer_max := 1.0
var slide_vector := Vector2.ZERO
# headbob vars
@export_group("headbob")
@export var headbob_frequency := 2.0
@export var headbob_amplitude := 0.04
var headbob_time := 0.0
# misc
var lerp_speed := 10.0
var air_lerp_speed := 3.0
var crouching_depth := 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# states
var walking := false
var sprinting := false
var crouching := false
var freelooking := false
var sliding := false
# input vars
const mouse_sens := 0.2
var direction = Vector3.ZERO
var last_velocity = Vector3.ZERO

func post_slide():
	sliding = false
	freelooking = false
	rotate_y(neck.rotation.y)
	neck.rotation.y = 0.0
	head.rotate_x(eyes.rotation.x)
	eyes.rotation.x = 0.0

func _ready() -> void:
	# capture mouse when player spawns
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	# handle camera
	if event is InputEventMouseMotion:
		if freelooking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens)) # rotate the neck left/right
			eyes.rotate_x(deg_to_rad(-event.relative.y * mouse_sens)) # rotate the head up/down
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens)) # rotate the body left/right
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens)) # rotate the head up/down
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89)) # limit vertical view

func _physics_process(delta: float) -> void:

	# movement input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")

	# handling sprint/crouch
	# crouching
	if Input.is_action_pressed("crouch") || sliding:
		# lerp speed
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		# lerp head
		head.position.y = lerp(head.position.y, crouching_depth, delta * lerp_speed)
		# toggle crouching collision
		standing_collision.disabled = true
		crouching_collision.disabled = false

		# handle sliding start
		if sprinting && input_dir != Vector2.ZERO && is_on_floor():
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir

		# states
		walking = false
		sprinting = false
		crouching = true
	# standing - only if theres room above
	elif !raycast.is_colliding():
		# toggle regular collision
		standing_collision.disabled = false
		crouching_collision.disabled = true
		# lerp head
		head.position.y = lerp(head.position.y, 0.5, delta * lerp_speed)
		# sprinting
		if Input.is_action_pressed("sprint"):
			# lerp speed
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
			# states
			walking = false
			sprinting = true
			crouching = false
		# wakling
		else:
			# lerp speed
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
			# states
			walking = true
			sprinting = false
			crouching = false

	# handle sliding
	if sliding:
		freelooking = true
		slide_timer -= delta
		if slide_timer <= 0:
			post_slide()

	# handle headbob

	# add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# handle jump
	if Input.is_action_pressed("jump") and is_on_floor():
		if sliding:
			post_slide()
			Input.action_release("jump")
		else:
			velocity.y = jump_velocity

	# handle landing
	if is_on_floor():
		if last_velocity.y < 0.0:
			pass

	# name this
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerp_speed)
	else:
		# apply air lerp only if movement keys are being pressed, not if momentum is moving player
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * air_lerp_speed)
	# handle sliding direction lock
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed
		current_speed = (slide_timer + 0.1) * slide_speed
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	last_velocity = velocity

	move_and_slide()

	headbob_time += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(headbob_time)

func headbob(float_headbob_time) -> Vector3:
	var headbob_position = Vector3.ZERO
	headbob_position.y = sin(float_headbob_time * headbob_frequency) * headbob_amplitude
	headbob_position.x = sin(float_headbob_time * headbob_frequency / 2) * headbob_amplitude
	return headbob_position
