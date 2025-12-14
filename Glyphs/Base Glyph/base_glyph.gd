extends Resource

class_name Glyph

@export var NAME: String = "Base Glyph"
@export_multiline var DESCRIPTION: String = ""

@export var TEXTURE: Texture2D

@export var SHARDS_FOR_LEVEL: int = 6

var glyph_level: int = 1
var player: Player

func hit(body: Node2D, dmg: int) :
  if player == null :
    return
  
  _on_hit(body, dmg)

func _on_hit(_body: Node2D, _dmg: int) :
  pass
