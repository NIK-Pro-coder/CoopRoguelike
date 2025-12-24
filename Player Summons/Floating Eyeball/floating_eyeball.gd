extends PlayerSummon

var theta: float = 0

func do_action(action_target: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(50, 50)).instantiate()
  dmg.global_position = action_target
  dmg.lifetime = .1
  dmg.damage = 5 * stat_changes.DAMAGE_PERCENT + stat_changes.DAMAGE
  dmg.attacker = master
  
  var l := Line2D.new()
  l.points = [global_position, action_target]
  l.default_color = Color("df7226")
  
  get_tree().get_root().add_child.call_deferred(l)
  
  Qol.create_timer(l.queue_free, .1)

func _process(_delta: float) -> void:
  global_position = master.global_position + Vector2.from_angle(theta) * 250

  theta += .03
