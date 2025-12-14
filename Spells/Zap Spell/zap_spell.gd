extends Spell

@onready var zap_area = $zap_area

func _cast(pos: Vector2) :
  var area: DamageArea = zap_area.duplicate()

  area.visible = true
  area.monitorable = true
  area.monitoring = true
  area.global_position = pos
  area.lifetime = .2
  area.damage = 30
  
  get_tree().get_root().add_child(area)
