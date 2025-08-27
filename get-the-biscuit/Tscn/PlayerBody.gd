extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Camera-relative movement
	var inputVec := Input.get_vector("Player Left", "Player Right", "Player Up", "Player Down")
	var camYaw := cameraPivot.global_transform.basis.get_euler().y
	var camBasis := Basis(Vector3.UP, camYaw)

	var moveDir := (camBasis * Vector3(inputVec.x, 0, inputVec.y)).normalized()

	if moveDir != Vector3.ZERO:
		velocity.x = moveDir.x * SPEED
		velocity.z = moveDir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# zoom vars
@export var minZoom := 2.0
@export var maxZoom := 8.0
@export var zoomSpeed := 1.0
var targetZoom := 4.0  # also the starting zoom

# camera movement/pivot logic
@onready var camera := $CamPivot/SpringCamArm3D/Camera3D as Camera3D
@onready var cameraPivot := $CamPivot as Node3D
@onready var cameraSpringArm := $CamPivot/SpringCamArm3D as SpringArm3D

@export_range(0.0, 1.0) var mouseSensitivity = 0.01
@export var cameraDistance = 4.0
@export var verticalLimit = Vector2(-30, 70)  # min and max vertical angle in degrees

var rotationY = 0.0  # vertical rotation
var rotationX = 0.0  # horizontal rotation
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Update rotation based on mouse movement
		rotationY -= event.relative.x * mouseSensitivity
		rotationX -= event.relative.y * mouseSensitivity

		# Clamp vertical rotation to avoid flipping upside down
		rotationX = clamp(rotationX, deg_to_rad(verticalLimit.x), deg_to_rad(verticalLimit.y))

		# Apply the rotations
		cameraPivot.rotation.y = rotationY
		camera.rotation.x = rotationX
		
		# zoom in/out logic
	elif event is InputEventMouseButton:
		if Input.is_action_pressed("Zoom In"):
			targetZoom = max(minZoom, targetZoom - zoomSpeed)
		elif Input.is_action_pressed("Zoom Out"):
			targetZoom = min(maxZoom, targetZoom + zoomSpeed)
		
# Smoothly Applies Zoom
func _process(delta):
	var currentZoom = cameraSpringArm.spring_length
	var newZoom = lerp(currentZoom, targetZoom, 10 * delta)
	cameraSpringArm.spring_length = newZoom
