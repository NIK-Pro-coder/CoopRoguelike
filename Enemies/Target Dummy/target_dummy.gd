extends Enemy

func _ready():
  if !OS.is_debug_build() :
    queue_free()

@onready var effectCont: GridContainer = %effectContainer

func _process(delta: float) -> void:
  super._process(delta)
  
  for i in effectCont.get_children() :
    i.queue_free()
  
  for i in effectcomp.stat_icons :
    var t := TextureRect.new()
    t.texture = effectcomp.stat_icons[i]
    t.custom_minimum_size = Vector2.ONE * 64
    
    effectCont.add_child(t)

func _physics_process(_delta: float) -> void:
  $RichTextLabel.text = "%s / %s" % [int(healthcomponent.health), healthcomponent.max_health]
  $healthBar.visible = true

func on_death():
  healthcomponent.revive(1)
  visible = true
