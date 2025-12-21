extends Weapon

var aoeScene = preload("res://Weapons/Battle Standard/battle_standard_aoe.tscn")
var aoe: Area2D

func on_equip(player: Player):
  if aoe :
    aoe.queue_free()
    aoe = null
    
  aoe = aoeScene.instantiate()
  player.add_child(aoe)

func on_unequip(_player: Player):
  if aoe :
    aoe.queue_free()
    aoe = null

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(200, 100)).add_animation(load("res://Weapons/Rusty Sword/sword_slash.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 100
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 100
  
  stop_atk(.2)
  set_cooldown(.4)
  
  return [dmg]
