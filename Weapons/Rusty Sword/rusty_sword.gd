extends Weapon

func normal_atk(player: Player, dir: Vector2) :
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(200, 100)).add_animation(load("res://Weapons/Rusty Sword/sword_slash.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 100
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 250
  
  return dmg

func special_atk(player: Player, dir: Vector2) :
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(100, 250)).add_animation(load("res://Weapons/Rusty Sword/sword_poke.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 125
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 250
  
  return dmg

func spawn_atk(player: Player, dir: Vector2):
  var dmg: DamageArea
  
  if combo == 2 :
    dmg = special_atk(player, dir)
  else :
    dmg = normal_atk(player, dir)
  
  stop_atk(.25)
  set_cooldown(.5)

  return [dmg]
