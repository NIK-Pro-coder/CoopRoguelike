extends Weapon

func spawn_atk(player: Player, dir: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(75, 200)).add_animation(load("res://Weapons/Rusty Spear/spear_poke.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 150
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 200
  
  stop_atk(.25)
  set_cooldown(.5)
  
  return [dmg]
