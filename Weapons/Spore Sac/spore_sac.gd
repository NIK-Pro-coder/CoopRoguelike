extends Weapon

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg_pot: Potion = load("res://Potions/poison_potion.tres").duplicate()
  dmg_pot.DURATION = 2
  
  var heal_pot: Potion = load("res://Potions/healing_potion.tres").duplicate()
  heal_pot.DURATION = 1
  
  for i in range(-45, 45, 10) :
    var dmg_player = Qol.create_atk(true).set_rect_shape(Vector2(50, 50)).add_sprite(load("res://Weapons/Spore Sac/spore.png")).instantiate()
    var dmg_enemy = Qol.create_atk().set_rect_shape(Vector2(50, 50)).instantiate()
    
    dmg_player.damage = 0
    dmg_player.global_position = player.global_position + dir * 100
    dmg_player.direction = (Vector2.from_angle(dir.angle() + deg_to_rad(i))) * randi_range(7, 13)
    dmg_player.lifetime = .5
    dmg_player.apply_effects.append(heal_pot)
    dmg_player.iframe_group = str(player.get_instance_id())
    
    dmg_enemy.damage = dmg_player.damage
    dmg_enemy.global_position = dmg_player.global_position
    dmg_enemy.direction = dmg_player.direction
    dmg_enemy.lifetime = dmg_player.lifetime
    dmg_enemy.apply_effects.append(dmg_pot)
    dmg_enemy.iframe_group = str(player.get_instance_id())
    dmg_enemy.damage = 5
  
  stop_atk(.1)
  set_cooldown(.5)
  
  return []
