extends PlayerSummon

func do_action(action_target: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(250, 150)).instantiate()
  dmg.global_position = global_position + (action_target - global_position).normalized() * 150
  dmg.rotation = action_target.angle_to_point(global_position)
  dmg.rotation_degrees += 90
  dmg.lifetime = .1
  dmg.damage = 10 * stat_changes.DAMAGE_PERCENT + stat_changes.DAMAGE
  dmg.knockback = (action_target - global_position).normalized() * (150 * master.stat_changes.KNOCKBACK_PERCENT + master.stat_changes.KNOCKBACK)
