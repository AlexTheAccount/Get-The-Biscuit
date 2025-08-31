extends Button

@export var upgradeId : String
@export var upgradeDesc : String

@onready var nameLabel := $Name
@onready var descLabel := $Desc
@onready var costLabel := $Cost

func _ready():
	if UpgradeManager.upgrades.has(upgradeId):
		var upgrade = UpgradeManager.upgrades[upgradeId]
		nameLabel.text = upgrade.display_name
		costLabel.text = str(upgrade.cost)

func UpdateUpgrade(currencyAmount):
	if UpgradeManager.upgrades.has(upgradeId):
		var upgrade = UpgradeManager.upgrades[upgradeId]
		var level = UpgradeManager.levels[upgradeId]
		disabled = not UpgradeManager.can_purchase(upgradeId)
		costLabel.text = str(upgrade.cost)


func _on_button_up() -> void:
	GameManager.uiClickPlayer.play()
	await get_tree().create_timer(GameManager.uiClickPlayer.stream.get_length()).timeout
	pass # Replace with function body.
