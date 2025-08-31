extends Control

@onready var continueNode := $Continue
@onready var settingsNode := $Settings
@onready var quitNode := $Quit

@export var pauseMenu := false

var settingsLoad = load("uid://7plmkuylx88q")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.isPaused = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ToggleAll():
	continueNode.visible = not continueNode.visible
	settingsNode.visible = not settingsNode.visible
	quitNode.visible = not quitNode.visible

func _on_continue_button_up() -> void:
	GameManager.isPaused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	self.queue_free()
	pass # Replace with function body.


func _on_settings_button_up() -> void:
	ToggleAll()
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	var addedSettings = settingsLoad.instantiate()
	add_child(addedSettings)
	pass # Replace with function body.


func _on_quit_button_up() -> void:
	if quitNode.text == "Your Progress won't be saved" && pauseMenu == false:
		GameManager.uiClickPlayer.play()
		await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
		GameManager.isPaused = false
		get_parent().get_parent().get_parent().ToggleAll()
		get_parent().get_parent().queue_free()
	else:
		quitNode.text = "Your Progress won't be saved"
		GameManager.uiClickPlayer.play()
		await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
		pauseMenu = false
	pass # Replace with function body.
