extends Weapon

@export var positive_effects: Array[Potion]
@export var negative_effects: Array[Potion]

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg_enemy = Qol.create_atk().set_rect_shape(Vector2(50, 50)).add_animation(load("res://Weapons/Deck Of Cards/thrown_card.tres")).instantiate()
  var dmg_player = Qol.create_atk(true).set_rect_shape(Vector2(50, 50)).instantiate()
  
  var neg_pot = negative_effects.pick_random().duplicate()
  var pos_pot = positive_effects.pick_random().duplicate()
  
  neg_pot.DURATION = 10
  pos_pot.DURATION = 10
  
  dmg_enemy.global_position = player.global_position
  dmg_enemy.direction = dir * 25
  dmg_enemy.attacker = player
  dmg_enemy.lifetime = .6
  dmg_enemy.rotation = dir.angle()
  
  dmg_player.damage = 0
  dmg_player.global_position = player.global_position
  dmg_player.direction = dir * 25
  dmg_player.attacker = player
  dmg_player.lifetime = .6
  dmg_player.rotation = dir.angle()
  
  if randf() >= .5 :
    dmg_enemy.apply_effects.append(neg_pot)
  dmg_player.apply_effects.append(pos_pot)
  
  stop_atk(.35)
  set_cooldown(.45)
  
  return [dmg_enemy]
