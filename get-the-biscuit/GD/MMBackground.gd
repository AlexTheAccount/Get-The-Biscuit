extends Node3D

var fallingBiscuitLoad = load("uid://2wjckococ0tw")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if randi_range(0, 50) == 1:
		var addedFallingBiscuit = fallingBiscuitLoad.instantiate()
		addedFallingBiscuit.position.y = 10
		addedFallingBiscuit.position.x = randi_range(-10, 10)
		addedFallingBiscuit.rotation = Vector3(randi_range(-10, 10), randi_range(-10, 10), randi_range(-10, 10))
		add_child(addedFallingBiscuit)
	pass
