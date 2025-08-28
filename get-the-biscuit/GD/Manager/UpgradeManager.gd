extends Node


signal upgradePurchased(id: String, newLevel: int)
signal currencyChanged(newAmount: int)

var upgrades := {} # Dictionary< String, UpgradeData >
var levels   := {} # Dictionary< String, int >
var currency := 0

func canPurchase(id: String) -> bool:
	var upgrade = upgrades[id]
	return upgrade and levels[id] < upgrade.maxLevel and currency >= upgrade.cost

func purchase(id: String) -> bool:
	if not canPurchase(id):
		return false
	var upgrade = upgrades[id]
	currency -= upgrade.cost
	levels[id] += 1
	return true
