extends Area3D

@export var itemId := "" # unique key
@export var amount := 1 # how many to add

func _on_body_entered(body: Node):
	if not body.is_in_group("Player"):
		return
	body.inventory[itemId] = body.inventory.get(itemId, 0) + amount
	for child in body.HUD.get_children():
		if child.trackedItem != null && child.trackedItem == itemId:
			child.text = itemId + ": " + str(body.inventory[itemId])
	queue_free() # remove the pickup
