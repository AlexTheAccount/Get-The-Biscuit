extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_up() -> void:
	get_parent().ToggleAll()
	queue_free()
	pass # Replace with function body.


func _on_sfx_slider_value_changed(value: float) -> void:
	GameManager.sfxVolume = value
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	GameManager.musicVolume = value
	pass # Replace with function body.
