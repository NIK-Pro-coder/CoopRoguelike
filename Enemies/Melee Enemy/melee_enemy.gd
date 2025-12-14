extends Enemy

func _process(_delta: float) -> void:
  super._process(_delta)
  
  if velocity.x < 0 :
    $Icon.flip_h = true
  elif velocity.x > 0 :
    $Icon.flip_h = false

func attack(_target: Node2D) :
  var area: DamageArea = damageAreaScene.instantiate()
  var shape = CollisionShape2D.new()
  
  shape.shape = RectangleShape2D.new()
  (shape.shape as RectangleShape2D).size = Vector2(200, 100)
  shape.debug_color = Color(1, 0, 0, .42)
  
  area.add_child(shape)

  var dir = (target.global_position - global_position).normalized()

  area.global_position = global_position + dir * 100
  area.rotation = dir.angle()
  area.rotation_degrees += 90
  area.lifetime = .25
  area.damage = 5
  area.knockback = dir.normalized() * 150
  area.attacker = self
  
  get_tree().get_root().add_child.call_deferred(area)
