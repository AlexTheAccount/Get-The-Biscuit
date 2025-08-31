extends Button

@export var upgradeName : String
var upgradeTier := 1
@export var upgradeDesc : String
@export var upgradeCost : int

@onready var nameLabel := $Name
@onready var descLabel := $Desc
@onready var costLabel := $Cost

func _ready():
	nameLabel.text = upgradeName + " Tier: " + str(upgradeTier)
	descLabel.text = upgradeDesc
	costLabel.text = "Cost: " + str(upgradeCost)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().get_parent().visible == false:
		visible = true
	if GameManager.player.inventory.size() > 0 && GameManager.player.inventory["Biscuit"] > upgradeCost:
		disabled = false
	else:
		disabled = true
	pass

func _on_button_up() -> void:
	visible = false
	disabled = true
	
	GameManager.player.inventory["Biscuit"] -= upgradeCost
	var child = GameManager.player.HUD.get_child(0)
	if child.trackedItem != null && child.trackedItem == "Biscuit":
		child.text = "Biscuit" + ": " + str(GameManager.player.inventory["Biscuit"])
	
	upgradeCost *= 2
	upgradeTier += 1
	
	nameLabel.text = upgradeName + " Tier: " + str(upgradeTier)
	costLabel.text = "Cost: " + str(upgradeCost)
	
	GameManager.player.UpgradePlayer(upgradeName)
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	pass # Replace with function body.
