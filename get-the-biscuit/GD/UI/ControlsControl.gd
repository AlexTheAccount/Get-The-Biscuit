extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.isPaused = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_up() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	GameManager.isPaused = false
	queue_free()
	pass # Replace with function body.
