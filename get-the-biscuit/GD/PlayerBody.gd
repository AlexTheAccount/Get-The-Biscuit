extends CharacterBody3D

@onready var HUD = $HUD
@onready var shopMenu = $"Shop Menu"

var SPEED = 5.0
var baseSpeed = SPEED
var JUMP_VELOCITY = 10
var baseJump = JUMP_VELOCITY

@export var shortJumpGravityMultipler := 2.0 # gravity multiplier when jump is released early
@export var fallGravityMultipler := 2.5 # gravity multiplier on the fall-down

@export var coyoteTime := 0.1 # seconds after leaving ground you can still jump
var coyoteTimer := 0.0

@export var jumpBufferTime := 0.2 # seconds before landing your jump input is stored for
var bufferTimer := 0.0

# Inventory
var inventory := {}

# Pause
var pauseLoad = load("uid://lc57evjjefum")
var addedPause

# Death
var deathLoad = load("uid://086fvgtlcfpr")
var addedDeath

# PlayerPivot
@export var turnSpeed := 8.0
@onready var playerPivot := $PlayerPivot as Node3D

# Audio
@onready var movementPlayer := $MovementPlayer as AudioStreamPlayer
@onready var jumpPlayer := $JumpPlayer as AudioStreamPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.player = self

func _input(event):
	if shopMenu.visible == false:
		if event.is_action_pressed("Pause") && addedPause == null && GameManager.isPaused == false:
			GameManager.uiClickPlayer.play()
			await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
			addedPause = pauseLoad.instantiate()
			add_child(addedPause)
		else:
			if event.is_action_pressed("Pause") && addedPause != null:
				addedPause._on_continue_button_up()

# Applying Upgrades to the Player
func UpgradePlayer(name: String):
	match name:
		"Speed Boost":
			SPEED = baseSpeed * 2
		"Jump Boost":
			JUMP_VELOCITY = baseJump * 2
	# add more cases as needed

func _physics_process(delta: float) -> void:
	if GameManager.isPaused == false:
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
		# Grab the base gravity vector
		var gravity = get_gravity()
		
		# Apply variable gravity
		if velocity.y < 0:
			# Player is falling: heavier gravity for snappy fall
			velocity += gravity * fallGravityMultipler * delta
		
		elif velocity.y > 0 and not Input.is_action_pressed("ui_accept"):
			# Player released jump while ascending: cut jump short
			velocity += gravity * shortJumpGravityMultipler * delta
		
		else:
			# Normal ascent (holding jump) or grounded
			velocity += gravity * delta
		
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
		
		# Rotate Player Mesh
		if moveDir.length() > 0.1:
			# Calculate the desired angle from moveDir
			var targetAngle = atan2(moveDir.x, moveDir.z)
			
			# Get the current mesh pivot angle
			var currentAngle = playerPivot.rotation.y
			
			# Interpolate toward the target angle
			var weight = clamp(turnSpeed * delta, 0, 1)
			var newAngle = lerp_angle(currentAngle, targetAngle, weight)
			
			# Apply the smoothed rotation
			playerPivot.rotation.y = newAngle
			
		# audio checks
		if Vector3(velocity.x, 0, velocity.z).length() > 0.1 && is_on_floor() == true && movementPlayer.is_playing() == false:
			movementPlayer.play()
		elif Vector3(velocity.x, 0, velocity.z).length() <= 0.1 || is_on_floor() == false:
			movementPlayer.stop()
		
		if velocity.y > 0 && jumpPlayer.is_playing() == false && Input.is_action_just_pressed("ui_accept"):
			jumpPlayer.play()

# Camera lag
@export var camHeight := 1.6
@export var maxLagDistance := 1.2 # max trailing distance behind motion
@export var lagResponse := 2.0 # higher = snappier
@export var lagAxisWeight := Vector3(1.0, 0.0, 1.0) # lag

@export var maxVerticalLag := 0.5 # how far up/down the camera trails
@export var verticalLagResponse := 5.0 # smoothness on Y axis
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
@export var rotationSmoothSpeed := 20.0 # higher = snappier, lower = more floaty
@export var verticalLimit = Vector2(-70, 30) # min and max vertical angle in degrees

var rotationY = 0.0 # vertical rotation
var rotationX = 0.0 # horizontal rotation
func _unhandled_input(event):
	if GameManager.isPaused == false:
		if event is InputEventMouseMotion:
			# Update rotation based on mouse movement
			rotationY -= event.relative.x * mouseSensitivity
			rotationX -= event.relative.y * mouseSensitivity
			
			# Clamp vertical rotation to avoid flipping upside down
			rotationX = clamp(rotationX, deg_to_rad(verticalLimit.x), deg_to_rad(verticalLimit.y))
			
			# zoom in/out logic
		elif event is InputEventMouseButton:
			if Input.is_action_pressed("Zoom In"):
				targetZoom = max(minZoom, targetZoom - zoomSpeed)
			elif Input.is_action_pressed("Zoom Out"):
				targetZoom = min(maxZoom, targetZoom + zoomSpeed)
		
func _process(delta):
	if position.y < -10 && addedDeath == null:
		addedDeath = deathLoad.instantiate()
		add_child(addedDeath)
	
	if GameManager.isPaused == false:
		# Smoothly Applies Zoom
		var currentZoom = cameraSpringArm.spring_length
		var newZoom = lerp(currentZoom, targetZoom, 10 * delta)
		cameraSpringArm.spring_length = newZoom
		
		# Camera lag based on player velocity
		var fullVelo := Vector3(velocity.x, 0, velocity.z)
		var speed := fullVelo.length()
		
		# We invert Y so camera lags opposite player motion (rising = camera dips, falling = camera rises)
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
		
		# Smoothly interpolate Yaw Pivot toward target yaw (rotationY)
		var smooth := 1.0 - exp(-rotationSmoothSpeed * delta)
		
		# Handles wrapping around ±PI correctly
		cameraPivot.rotation.y = lerp_angle(cameraPivot.rotation.y, rotationY, smooth)
		tiltPivot.rotation.x = lerp_angle(tiltPivot.rotation.x, rotationX, smooth)
		
		# Apply to pivot without touching rotation
		cameraPivot.position = basePivotPos + Vector3(0, camHeight, 0) + lagOffset
	
