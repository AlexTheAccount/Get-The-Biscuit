extends Control

var levelLoad = load("uid://bjst3v4cmfhrq")
var settingsLoad = load("uid://7plmkuylx88q")

@onready var playNode := $Play
@onready var settingsNode := $Settings
@onready var quitNode := $Quit

@onready var musicPlayer := $MusicPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.uiClickPlayer = $UIClickPlayer
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if musicPlayer.is_playing() == false:
		musicPlayer.play()
	pass

func ToggleAll():
	playNode.visible = not playNode.visible
	settingsNode.visible = not settingsNode.visible
	quitNode.visible = not quitNode.visible

func _on_play_button_up() -> void:
	ToggleAll()
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	GameManager.stageCounter = 0
	var addedLevel = levelLoad.instantiate()
	add_child(addedLevel)
	pass # Replace with function body.


func _on_settings_button_up() -> void:
	ToggleAll()
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	var addedSettings = settingsLoad.instantiate()
	add_child(addedSettings)
	pass # Replace with function body.


func _on_quit_button_up() -> void:
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	get_tree().quit()
	pass # Replace with function body.
