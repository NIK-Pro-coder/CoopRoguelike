extends Weapon

func spawn_atk(player: Player, dir: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(125, 125)).add_sprite(load("res://Weapons/Burning Coals/burning_coals.png")).instantiate()
  dmg.lifetime = 10
  dmg.global_position = player.global_position + dir * 150
  dmg.attacker = player
  dmg.add_to_group("roompart")
  dmg.iframe_group = str(player.get_instance_id())
  
  isAttacking = false
  set_cooldown(.5)
  
  return [dmg]
