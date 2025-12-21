extends Weapon

func spawn_atk(player: Player, dir: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(125, 125)).add_sprite(load("res://Weapons/Knockback Stick/knockback_stick_swing.png")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 150
  dmg.attacker = player
  dmg.knockback = dir.normalized() * (250 if combo < 2 else 1000)
  
  stop_atk(.25)
  set_cooldown(.4)
  
  return [dmg]
