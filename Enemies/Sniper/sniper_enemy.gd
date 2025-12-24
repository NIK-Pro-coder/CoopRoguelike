extends Enemy

var t: GenericTelegraph

func attack(atk_target: Node2D):
  if t :
    t.queue_free()
    t = null
  
  t = Qol.create_telegraph(Vector2(5000, 50), 1)
  t.rotation = global_position.angle_to_point(atk_target.global_position)
  t.global_position = global_position + (atk_target.global_position - global_position).normalized() * 2500
  
  t.telegraph_finished.connect(func() :
    t.queue_free()
    var d: DamageArea = Qol.create_atk(true).set_rect_shape(t.SHAPE_SIZE).instantiate()
    d.rotation = t.rotation
    d.global_position = t.global_position
    d.damage = 30
    d.piercing = -1
    
    var l := Line2D.new()
    l.points = [global_position, global_position + (t.global_position - global_position) * 2]
    l.default_color = Color.RED
    
    get_tree().get_root().add_child.call_deferred(l)
    
    Qol.create_timer(l.queue_free, .1)
  )

func on_death():
  super.on_death()
  if t :
    t.queue_free()
