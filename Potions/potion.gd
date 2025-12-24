extends Item
class_name Potion

@export var DURATION: float = 10
@export var EFFECTS: Array[StatChange] = []

@export var EFFECT_ICON: Texture2D = preload("res://Potions/Sprites/Buff Icons/buff_bg.png")

@export var DOT: int = 0

func get_description() -> String:
  return "[b]- Potion -[/b]\n" + DESCRIPTION
