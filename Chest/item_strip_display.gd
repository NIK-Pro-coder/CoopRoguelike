extends Control

@export var DISPLAY_ITEM: Item

@export var COLORS: Dictionary[Item.Rarity, Color]

func _ready() -> void:
  $raritycol.add_theme_stylebox_override("panel", $raritycol.get_theme_stylebox("panel").duplicate())

func _process(_delta: float) -> void:
  $RichTextLabel.text = DISPLAY_ITEM.NAME
  $TextureRect.texture = DISPLAY_ITEM.TEXTURE if DISPLAY_ITEM.TEXTURE else PlaceholderTexture2D.new()
    
  ($raritycol.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = COLORS[DISPLAY_ITEM.RARITY]
