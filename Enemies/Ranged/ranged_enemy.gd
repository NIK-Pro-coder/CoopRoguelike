extends Enemy

@onready var bullet: DamageArea = %bullet

func _process(_delta: float) -> void:
  super._process(_delta)
  
  if velocity.x < 0 :
    $Icon.flip_h = true
  elif velocity.x > 0 :
    $Icon.flip_h = false

func attack(_target: Node2D) :
  var area: DamageArea = bullet.duplicate()

  var dir = (target.global_position - global_position).normalized()

  area.visible = true
  area.monitorable = true
  area.monitoring = true
  area.lifetime = 25
  area.global_position = global_position + dir * 100
  area.rotation = dir.angle()
  area.rotation_degrees += 90
  area.direction = (target.global_position - global_position).normalized() * 10
  area.attacker = self
  area.damage = int((5 * stat_tracker.DAMAGE_PERCENT + stat_tracker.DAMAGE) * wave_scaling)
  
  get_tree().get_root().add_child.call_deferred(area)
