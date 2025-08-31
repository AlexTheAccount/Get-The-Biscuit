extends Area3D

@export var itemId := "" # unique key
@export var amount := 1 # how many to add
@onready var biscuitPlayer := $BiscuitPlayer as AudioStreamPlayer
@onready var pickupPlayer := $PickupPlayer as AudioStreamPlayer

func _on_body_entered(body: Node):
	if biscuitPlayer.is_playing() == false:
		if not body.is_in_group("Player"):
			return
		biscuitPlayer.play()
		pickupPlayer.play()
		body.inventory[itemId] = body.inventory.get(itemId, 0) + amount
		var child = body.HUD.get_child(0)
		if child.trackedItem != null && child.trackedItem == itemId:
			child.text = itemId + ": " + str(body.inventory[itemId])
		
		visible = false
		await get_tree().create_timer(biscuitPlayer.stream.get_length()).timeout
		queue_free() # remove the pickup
