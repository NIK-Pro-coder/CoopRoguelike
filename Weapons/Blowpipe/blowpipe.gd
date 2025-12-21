extends Weapon

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg = Qol.create_atk().set_rect_shape(Vector2(50, 50)).add_sprite(load("res://Weapons/Blowpipe/blowpipe_dart.png")).instantiate()
  dmg.rotation = dir.angle()
  dmg.global_position = player.global_position
  dmg.direction = dir * 25
  dmg.lifetime = .5
  dmg.apply_effects.append(load("res://Potions/poison_potion.tres").duplicate())
  dmg.apply_effects[-1].DURATION = 2
  dmg.piercing = 0
  
  stop_atk(.1)
  set_cooldown(.5)
  
  return [dmg]
