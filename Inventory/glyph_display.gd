extends Panel

class_name GlyphDisplay

var GLYPH: Glyph
var SHARD_NUM: int = 0

@onready var icon: TextureRect = %icon
@onready var gname: RichTextLabel = %gname
@onready var text: RichTextLabel = %text

var color = Color.BLACK

func _ready() -> void:
  icon.texture = GLYPH.TEXTURE if GLYPH.TEXTURE else PlaceholderTexture2D.new()
  
  add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate())

func _process(_delta: float) -> void:
  gname.text = GLYPH.NAME
  text.text = "%s / %s shard%s" % [SHARD_NUM, GLYPH.SHARDS_FOR_LEVEL, "" if SHARD_NUM == 1 else "s"]

  (get_theme_stylebox("panel") as StyleBoxFlat).bg_color = color
