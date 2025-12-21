extends Spell

func cast_action(player: Player) -> bool:
  var enemy: Node2D = get_closest_enemy(player)
  
  if enemy == null :
    return false
  
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(250, 250)).instantiate()
  dmg.damage = 15 * powerMultiplier
  dmg.global_position = enemy.global_position
  
  return true
