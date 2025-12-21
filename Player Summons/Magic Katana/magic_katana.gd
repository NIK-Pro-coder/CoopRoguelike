extends PlayerSummon

var slot: float = 0

func do_action(_action_target: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(250, 250)).instantiate()
  dmg.global_position = global_position
  dmg.lifetime = .1
  dmg.damage = 5 * stat_changes.DAMAGE_PERCENT + stat_changes.DAMAGE
  
  $AnimationPlayer.play("spin")

func _process(_delta: float) -> void:
  if target == get_default_target() :
    global_position = master.global_position + Vector2(75, 0) * (slot + 1) * (1 if master.sprite.flip_h else -1)
