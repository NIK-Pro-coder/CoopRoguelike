extends Weapon

func spawn_atk(player: Player, dir: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(75, 75)).add_animation(load("res://Weapons/Rusty Dagger/dagger_poke.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 150
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 100
  dmg.iframe_amount = .25
  dmg.iframe_group = str(player.get_instance_id())
  
  isAttacking = false
  set_cooldown(.1)
  
  return [dmg]
