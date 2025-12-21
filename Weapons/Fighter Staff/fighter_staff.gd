extends Weapon

var fighterScene = preload("res://Player Summons/Figther Construct/fighter_construct.tscn")

var construct: PlayerSummon

func on_unequip(_player: Player):
  if construct :
    construct.queue_free()
    construct = null

func on_equip(player: Player):
  if construct :
    construct.queue_free()
    construct = null
  
  construct = fighterScene.instantiate()
  construct.global_position = player.global_position
  construct.master = player
  
  player.get_tree().get_root().add_child(construct)
  
  construct.healthcomponent.death.connect(func():
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
