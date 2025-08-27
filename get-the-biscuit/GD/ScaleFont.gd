extends Node

var base_font_size : int
var base_size : Vector2
var label : Label

func _enter_tree():
	# caches initial sizes
	label = get_parent() as Label
	base_size = label.size
	base_font_size = label.get_theme_font_size("font_size", label.get_class())
	label.resized.connect(set_text_size)

func set_text_size():
	var new_size = label.size;

	# scale base on control width
	var scale = new_size.x / base_size.x;
	var scaled_size :int = floor(base_font_size * scale);

	# apply scale
	label.add_theme_font_size_override("font_scale", scaled_size);

func _exit_tree():
	# remember to disconnect when exiting!
	label.resized.disconnect(set_text_size)
