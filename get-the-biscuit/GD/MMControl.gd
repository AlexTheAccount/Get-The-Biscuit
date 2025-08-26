extends Control

var levelLoad = load("uid://bjst3v4cmfhrq")

var playNode
var settingsNode
var quitNode
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playNode = get_node("Play")
	settingsNode = get_node("Settings")
	quitNode = get_node("Quit")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ToggleAll():
	playNode.visible = not playNode.visible
	settingsNode.visible = not settingsNode.visible
	quitNode.visible = not quitNode.visible

func _on_play_button_up() -> void:
	ToggleAll()
	var addedLevel = levelLoad.instantiate()
	add_child(addedLevel)
	pass # Replace with function body.


func _on_settings_button_up() -> void:
	pass # Replace with function body.


func _on_quit_button_up() -> void:
	get_tree().quit()
	pass # Replace with function body.
