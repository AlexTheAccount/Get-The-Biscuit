extends Node3D

@export var platformScenes: Array[PackedScene] = []
@export var itemScene: PackedScene
@export var maxPlatforms := 250
@export var spawnRadius := 10
@export var spacing := 12
@export var randomness := 0.5  # 0 = grid, 1 = chaos
@export var itemChance := 0.3  # 0.0 to 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func generate():
	var directions = [
		Vector3(1, 0, 0), Vector3(-1, 0, 0),
		Vector3(0, 0, 1), Vector3(0, 0, -1),
		Vector3(1, 0, 1), Vector3(-1, 0, -1),
		Vector3(1, 0, -1), Vector3(-1, 0, 1)
	]
	
	var used_positions = { Vector3.ZERO: true }
	var spawn_list = [ Vector3.ZERO ]
	
	for i in range(maxPlatforms):
		# Picks an existing platform to branch from
		var parent_pos = spawn_list[randi() % spawn_list.size()]
		
		# Pick a direction
		var dir = directions[randi() % directions.size()].normalized()
		var offset = dir * spacing
		
		# randomness
		offset += Vector3(
		randf_range(-randomness, randomness),
		randf_range(-randomness * 0.5, randomness * 0.5),
		randf_range(-randomness, randomness)
		) * spacing
		
		var new_pos = (parent_pos + offset).snapped(Vector3.ONE * spacing)
		if used_positions.has(new_pos):
			continue
		
		# Record new
		used_positions[new_pos] = true
		spawn_list.append(new_pos)
		
		# make new instance
		var scene = platformScenes[randi() % platformScenes.size()]
		var plat  = scene.instantiate() as Node3D
		plat.global_position = new_pos
		add_child(plat)
		
		if randf() < itemChance:
			var item = itemScene.instantiate()
			item.global_position = new_pos + Vector3.UP * 1.5
			add_child(item)
