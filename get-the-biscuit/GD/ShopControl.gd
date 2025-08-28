extends Control

func EnterShop():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_exit_shop_button_up() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false
	pass # Replace with function body.
