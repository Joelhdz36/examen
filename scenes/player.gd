extends CharacterBody3D


@onready var flashlight: SpotLight3D = %Flashlight

@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = %Head

@export var player_map_context:GUIDEMappingContext
@export var movement_action:GUIDEAction
@export var flashlight_action:GUIDEAction
@export var camera_rotation_action:GUIDEAction

#@export var cam_s

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const SENSITIVITY = 0.01

#Bob variables
const BOB_FREQ = 7.0
const  BOB_AMP = .015
var t_bob = 0.0


func _ready() -> void:
	GUIDE.enable_mapping_context(player_map_context)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func camera_rotation(event):
	head.rotate_y(-event.relative.x * SENSITIVITY)
	camera_3d.rotate_x(-event.relative.y * SENSITIVITY)
	camera_3d.rotation.x = clamp(camera_3d.rotation.x,deg_to_rad(-40), deg_to_rad(60))

func _process(_delta: float) -> void:
	if flashlight_action.is_triggered():
		flashlight.visible = !flashlight.visible

	if camera_rotation_action._value:
		var camera_rotation_value:Dictionary = {"relative": camera_rotation_action._value}
		camera_rotation(camera_rotation_value)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := movement_action.value_axis_3d

	var direction := (head.transform.basis * input_dir).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera_3d.transform.origin = head_bob(t_bob)
	move_and_slide()


func head_bob(time:float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ /2) * BOB_AMP
	return pos
