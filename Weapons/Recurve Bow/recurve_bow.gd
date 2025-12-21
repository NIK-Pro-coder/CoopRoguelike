extends Weapon

func spawn_atk(player: Player, dir: Vector2):
  var tex: Texture2D = load("res://Weapons/Recurve Bow/arrow.png")
  
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(75, 75)).add_sprite(tex).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .5
  dmg.global_position = player.global_position + dir * 100
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 100
  dmg.direction = dir.normalized() * 50
  dmg.piercing = 0
  
  isAttacking = false
  set_cooldown(.3)
  
  return [dmg]
