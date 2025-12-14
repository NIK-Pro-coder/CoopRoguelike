extends Panel

class_name InvSlot

@onready var TEXTURE: TextureRect = $MarginContainer/TextureRect

func _ready() -> void:
  add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate())
