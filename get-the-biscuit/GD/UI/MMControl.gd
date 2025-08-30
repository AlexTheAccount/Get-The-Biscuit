extends Control

var levelLoad = load("uid://bjst3v4cmfhrq")
var settingsLoad = load("uid://7plmkuylx88q")

@onready var playNode := $Play
@onready var settingsNode := $Settings
@onready var quitNode := $Quit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	GameManager.stageCounter = 0
	var addedLevel = levelLoad.instantiate()
	add_child(addedLevel)
	pass # Replace with function body.


func _on_settings_button_up() -> void:
	ToggleAll()
	var addedSettings = settingsLoad.instantiate()
	add_child(addedSettings)
	pass # Replace with function body.


func _on_quit_button_up() -> void:
	get_tree().quit()
	pass # Replace with function body.
