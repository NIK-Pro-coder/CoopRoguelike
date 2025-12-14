extends Panel

class_name LobbyPLayerDisp

@onready var texture: TextureRect = %icon
@onready var pname: RichTextLabel = %name
@onready var pready: RichTextLabel = %readyState
@onready var wname: RichTextLabel = %wname
@onready var wdesc: RichTextLabel = %wdesc

var player_name: String = ""
var player_ready: bool = false
var player_hue: float = 0.0

var weapon_name: String = "Weapon name"
var weapon_desc: String = "Lorem ipsum dolor sit amet"

func _ready() -> void:
  texture.material = texture.material.duplicate()

func _process(_delta: float) -> void:
  wname.text = weapon_name
  wdesc.text = weapon_desc

  pname.text = player_name
  
  if player_ready :
    pready.text = "Ready"
  else :
    pready.text = "Not Ready"
  
  texture.material.set_shader_parameter("hue_shift", player_hue)
