extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 10

@export var coyoteTime := 0.1         # seconds after leaving ground you can still jump
@export var jumpBufferTime := 0.2    # seconds before landing your jump input is stored for

var coyoteTimer := 0.0
var bufferTimer := 0.0
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	# Update timers
	if is_on_floor():
		coyoteTimer = coyoteTime
	else:
		coyoteTimer = max(coyoteTimer - delta, 0)
	
	# Capture jump input into buffer
	if Input.is_action_just_pressed("ui_accept"):
		bufferTimer = jumpBufferTime
	else:
		bufferTimer = max(bufferTimer - delta, 0)
	
	# Perform jump if either on floor (or within coyote) and buffered
	if bufferTimer > 0 && coyoteTimer > 0:
		velocity.y = JUMP_VELOCITY
		bufferTimer = 0
		coyoteTimer = 0
	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
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

# Camera lag
@export var camHeight := 1.6
@export var maxLagDistance := 1.2 # max trailing distance behind motion
@export var lagResponse := 10.0 # higher = snappier
@export var lagAxisWeight := Vector3(1.0, 0.0, 1.0) # lag

@export var maxVerticalLag := 0.5        # how far up/down the camera trails
@export var verticalLagResponse := 5.0   # smoothness on Y axis
var lagOffset := Vector3.ZERO
var basePivotPos: Vector3

# zoom vars
@export var minZoom := 2.0
@export var maxZoom := 8.0
@export var zoomSpeed := 1.0
var targetZoom := 4.0  # also the starting zoom

# camera movement/pivot logic
@onready var cameraPivot := $CamPivot as Node3D
@onready var tiltPivot := $CamPivot/TiltPivot as Node3D
@onready var cameraSpringArm := $CamPivot/TiltPivot/SpringCamArm3D as SpringArm3D
@onready var camera := $CamPivot/TiltPivot/SpringCamArm3D/Camera3D as Camera3D

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
		tiltPivot.rotation.x = rotationX
		
		# zoom in/out logic
	elif event is InputEventMouseButton:
		if Input.is_action_pressed("Zoom In"):
			targetZoom = max(minZoom, targetZoom - zoomSpeed)
		elif Input.is_action_pressed("Zoom Out"):
			targetZoom = min(maxZoom, targetZoom + zoomSpeed)
		
func _process(delta):
	# Smoothly Applies Zoom
	var currentZoom = cameraSpringArm.spring_length
	var newZoom = lerp(currentZoom, targetZoom, 10 * delta)
	cameraSpringArm.spring_length = newZoom
	
	# Camera lag based on player velocity
	var fullVelo := Vector3(velocity.x, 0, velocity.z)
	var speed := fullVelo.length()
	
#    We invert Y so camera lags opposite player motion (rising = camera dips, falling = camera rises)
	var rawYoffset := -velocity.y * 0.1 # scale factor—you can tweak
	var desiredY = clamp(rawYoffset, -maxVerticalLag, maxVerticalLag)
	var desiredXZ := Vector3.ZERO
	
	var desiredOffset := Vector3(
		desiredXZ.x,
		desiredY,
		desiredXZ.z
	)
	if speed > 0.05:
		desiredOffset = -fullVelo.normalized() * maxLagDistance
	
	# Smooth separately on each axis
	var smoothHor := 1.0 - exp(-lagResponse * delta)
	var smoothVert := 1.0 - exp(-verticalLagResponse * delta)
	lagOffset.x = lerp(lagOffset.x, desiredOffset.x, smoothHor)
	lagOffset.y = lerp(lagOffset.y, desiredOffset.y, smoothVert)
	lagOffset.z = lerp(lagOffset.z, desiredOffset.z, smoothHor)
	
	# Framerate-independent smoothing factor
	var t := 1.0 - exp(-lagResponse * delta)
	lagOffset = lagOffset.lerp(desiredOffset, t)
	
	# Safety clamp to prevent overshoot
	if lagOffset.length() > maxLagDistance:
		lagOffset = lagOffset.normalized() * maxLagDistance
	
	# Apply to pivot without touching rotation
	cameraPivot.position = basePivotPos + Vector3(0, camHeight, 0) + lagOffset
