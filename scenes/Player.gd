extends CharacterBody3D

@onready var camera = $Camera3D

@export_category("Player Settings")
@export var speed := 5.0
@export var jump_velocity := 4.5
@export var vertical_rotation_limit := 80.0

@export_category("Mouse Settings")
@export var mouse_sensitivity := 0.2


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_rotation := 0.0


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		vertical_rotation -= event.relative.y * mouse_sensitivity
		vertical_rotation = clamp(vertical_rotation, -vertical_rotation_limit, vertical_rotation_limit)
		camera.rotation_degrees.x = vertical_rotation
		
	_notification(event)
		

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var vertical_rotation = camera

func _physics_process(delta):
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

func shoot():
	return
