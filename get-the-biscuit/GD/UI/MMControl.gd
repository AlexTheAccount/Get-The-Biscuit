extends Control

var levelLoad = load("uid://bjst3v4cmfhrq")
var settingsLoad = load("uid://7plmkuylx88q")
var creditsLoad = load("uid://cu4jhaanlju30")
var mmBackground = load("uid://cvye3flbatt88")
@onready var addedMMBackground = $MMBackground

@onready var playNode := $Play
@onready var settingsNode := $Settings
@onready var creditsNode := $Credits

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
	creditsNode.visible = not creditsNode.visible
	if addedMMBackground == null:
		var addedMMBackground = mmBackground.instantiate()
		add_child(addedMMBackground)

func _on_play_button_up() -> void:
	ToggleAll()
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	addedMMBackground.queue_free()
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

func _on_credits_button_up() -> void:
	ToggleAll()
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	var addedCredits = creditsLoad.instantiate()
	add_child(addedCredits)
	pass # Replace with function body.
