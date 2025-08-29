extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.isPaused = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_button_up() -> void:
	GameManager.isPaused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.queue_free()
	pass # Replace with function body.


func _on_settings_button_up() -> void:
	pass # Replace with function body.


func _on_quit_button_up() -> void:
	GameManager.isPaused = false
	get_parent().get_parent().get_parent().ToggleAll()
	get_parent().get_parent().queue_free()
	pass # Replace with function body.
