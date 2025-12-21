extends Weapon

func spawn_atk(player: Player, dir: Vector2):
  var dmg_enemy: DamageArea = Qol.create_atk().set_rect_shape(Vector2(175, 100)).instantiate()
  dmg_enemy.rotation = dir.angle()
  dmg_enemy.lifetime = .25
  dmg_enemy.global_position = player.global_position + dir * 100
  dmg_enemy.attacker = player
  dmg_enemy.knockback = dir.normalized() * 250
  dmg_enemy.damage = 5
  
  var dmg_player: DamageArea = Qol.create_atk(true).set_rect_shape(Vector2(175, 100)).add_sprite(load("res://Weapons/Syringes/syringe_atk.png")).instantiate()
  dmg_player.rotation = dir.angle()
  dmg_player.lifetime = .25
  dmg_player.global_position = player.global_position + dir * 100
  dmg_player.attacker = player
  dmg_player.damage = -5
  
  stop_atk(.2)
  set_cooldown(.6)
  
  return []
