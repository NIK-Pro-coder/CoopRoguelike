extends Weapon

var summonScene = preload("res://Player Summons/Magic Katana/magic_katana.tscn")

var summons: Array[PlayerSummon]

func on_unequip(_player: Player):
  for i in summons :
    i.queue_free()
  summons.clear()

func on_equip(player: Player):
  for i in summons :
    i.queue_free()
  summons.clear()
  
  for i in range(5) :
    var summon = summonScene.instantiate()
    summon.slot = i
    summon.master = player
    summon.global_position = player.global_position + Vector2(75, 0) * (i + 1) * (1 if player.sprite.flip_h else -1)
    
    summons.append(summon)
    
    player.get_tree().get_root().add_child(summon)
  
    summon.healthcomponent.death.connect(func():
      summons.erase(summon)
      
      if len(summons) == 0 :
        Qol.create_timer(on_equip.bind(player), 2)
    )

func spawn_atk(player: Player, dir: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(200, 100)).add_animation(load("res://Weapons/Rusty Sword/sword_slash.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 100
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 100
  
  stop_atk(.1)
  set_cooldown(.4)
  
  return [dmg]
