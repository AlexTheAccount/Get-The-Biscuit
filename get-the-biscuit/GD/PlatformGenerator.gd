extends Node3D

@export var platformScenes: Array[PackedScene] = []
@export var itemScene: PackedScene
@export var maxPlatforms := 250
@export var spawnRadius := 10
@export var spacing := 12
@export var randomness := 0.5  # 0 = grid, 1 = chaos
@export var itemChance := 0.3  # 0.0 to 1.0

var player

# Reset Timer
@export var resetTimer := 60.0
var resetTimerNode
var timeLeft := 0.0

# Safe zone tracking
@onready var safeZone := $Mesh3D/SafeZone as Area3D
var playerSafe := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeLeft = resetTimer
	
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
		resetTimerNode = player.get_node("HUD").get_node("TimerLabel")
	
	Reset()
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	if GameManager.isPaused == false:
		# Countdown
		timeLeft -= delta
		
		if timeLeft <= 0:
			timeLeft = resetTimer
			Reset()
		
		resetTimerNode.text = str(int(timeLeft))

func Reset() -> void:
	# Death check 
	#if playerSafe == false:
		#player.queue_free()  # or call your custom die() method
	
	# Clear old platforms and items
	for child in get_children():
		if child.name != "CentralMesh":
			child.queue_free()

	# Generate new layout
	generate()
	
func generate():
	var directions = [
		Vector3(1, 0, 0), Vector3(-1, 0, 0),
		Vector3(0, 0, 1), Vector3(0, 0, -1),
		Vector3(1, 0, 1), Vector3(-1, 0, -1),
		Vector3(1, 0, -1), Vector3(-1, 0, 1)
	]
	
	var usedPositions = { Vector3.ZERO: true }
	var spawnList = [ Vector3.ZERO ]
	
	for i in range(maxPlatforms):
		# Picks an existing platform to branch from
		var parentPos = spawnList[randi() % spawnList.size()]
		
		# Pick a direction
		var dir = directions[randi() % directions.size()].normalized()
		var offset = dir * spacing
		
		# randomness
		offset += Vector3(
		randf_range(-randomness, randomness),
		randf_range(-randomness * 0.5, randomness * 0.5),
		randf_range(-randomness, randomness)
		) * spacing
		
		var newPos = (parentPos + offset).snapped(Vector3.ONE * spacing)
		if usedPositions.has(newPos):
			continue
		
		# Record new
		usedPositions[newPos] = true
		spawnList.append(newPos)
		
		# make new instance
		var scene = platformScenes[randi() % platformScenes.size()]
		var plat  = scene.instantiate() as Node3D
		plat.global_position = newPos
		add_child(plat)
		
		if randf() < itemChance:
			var item = itemScene.instantiate()
			item.global_position = newPos + Vector3.UP * 1.5
			add_child(item)

# Safe zone methods
func _on_safe_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		playerSafe = true


func _on_safe_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		playerSafe = false
