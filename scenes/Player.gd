extends CharacterBody3D

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D

@export_category("Player Settings")
@export var speed := 5.0
@export var jump_velocity := 4.5
@export var vertical_rotation_limit := 80.0

@export_category("Mouse Settings")
@export var mouse_sensitivity := 0.2


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_rotation := 0.0
var life = 150

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		vertical_rotation -= event.relative.y * mouse_sensitivity
		vertical_rotation = clamp(vertical_rotation, -vertical_rotation_limit, vertical_rotation_limit)
		camera.rotation_degrees.x = vertical_rotation
	
	if Input.is_action_just_pressed("shoot"):
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
		

func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


	
@rpc("any_peer")
func receive_damage():
	life -= 40
	if life <= 0:
		life  = 150
		position = Vector3(0.0, 1.5, 0.0)
		
	
