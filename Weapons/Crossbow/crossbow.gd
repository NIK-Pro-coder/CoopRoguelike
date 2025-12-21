extends Weapon

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(100, 25)).add_sprite(load("res://Weapons/Crossbow/crossbow_bolt.png")).instantiate()
  dmg.rotation = dir.angle()
  dmg.global_position = player.global_position
  dmg.direction = dir * 35
  dmg.piercing = 1
  dmg.lifetime = 1.5
  
  stop_atk(.2)
  set_cooldown(.75)
  
  return [dmg]
