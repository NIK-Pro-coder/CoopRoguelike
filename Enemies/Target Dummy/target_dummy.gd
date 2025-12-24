extends Enemy

func _ready():
  if !OS.is_debug_build() :
    queue_free()

@onready var effectCont: GridContainer = %effectContainer

func _process(delta: float) -> void:
  super._process(delta)
  
  for i in effectCont.get_children() :
    i.queue_free()
  
  for i in effectComp.stat_icons :
    var t := TextureRect.new()
    t.texture = effectComp.stat_icons[i]
    t.custom_minimum_size = Vector2.ONE * 64
    
    effectCont.add_child(t)

func on_death():
  hpComp.revive(1)
  visible = true
