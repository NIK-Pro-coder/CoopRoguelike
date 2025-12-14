extends Control
class_name PowerTemplate

@export var power: Power

var hue_shift: float = 0

func getPlaceholder() -> PlaceholderTexture2D :
  var place = PlaceholderTexture2D.new()
  
  place.size = Vector2(96, 96)
  
  return place
  
@export var stacks = 0

func _ready() -> void:
  $TextureRect.material = $TextureRect.material.duplicate()
  ($TextureRect.material as ShaderMaterial).set_shader_parameter("hue_shift", hue_shift)
  
  $TextureRect/MarginContainer/VBoxContainer/icon.texture = power.TEXTURE if power.TEXTURE != null else getPlaceholder()
  $TextureRect/MarginContainer/VBoxContainer/powerName.text = power.NAME
  $TextureRect/MarginContainer/VBoxContainer/powerDesc.text = power.DESC

  var stylebox := StyleBoxFlat.new()
  stylebox.corner_radius_bottom_left = 16
  stylebox.corner_radius_top_left = 16
  stylebox.corner_radius_bottom_right = 16
  stylebox.corner_radius_top_right = 16
  $TextureRect.add_theme_stylebox_override("panel", stylebox)

  $TextureRect/MarginContainer/VBoxContainer/levelNum.text = ("%s -> %s stacks" % [stacks, stacks + 1]) if stacks > 0 else "New!"
