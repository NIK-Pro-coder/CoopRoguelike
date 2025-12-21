extends PlayerSummon

func _ready() -> void:
  if !OS.is_debug_build() :
    queue_free()

@onready var effectCont: GridContainer = %effectContainer

func _physics_process(_delta: float) -> void:
  pass

func _process(delta: float) -> void:
  super._process(delta)
  
  for i in effectCont.get_children() :
    i.queue_free()
  
  for i in effectcomp.stat_icons :
    var t := TextureRect.new()
    t.texture = effectcomp.stat_icons[i]
    t.custom_minimum_size = Vector2.ONE * 64
    
    effectCont.add_child(t)
  
  if healthcomponent.health >= healthcomponent.max_health :
    healthcomponent.dealDmg(healthcomponent.max_health - 1)
  
  $RichTextLabel.text = "%s / %s" % [int(healthcomponent.health), healthcomponent.max_health]
  $healthbar.visible = true
