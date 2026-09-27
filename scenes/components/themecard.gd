@tool
extends Control

@export var text: String = "Default Text":
	set(value):
		text = value
		_update_ui()

@export var image: Texture2D:
	set(value):
		image = value
		_update_ui()

func _ready() -> void:
	_update_ui()

func _update_ui():
	if not is_inside_tree():
		await ready
		
	%Label.text = text
	%TextureRect.texture = image
