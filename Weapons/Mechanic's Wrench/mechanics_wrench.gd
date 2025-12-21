extends Weapon

var turretScene = preload("res://Weapons/Mechanic's Wrench/mechanics_wrench_turret.tscn")
var turret: MechanicTurret

func on_equip(player: Player):
  if turret :
    turret.queue_free()
    turret = null
    
  turret = turretScene.instantiate()
  turret.position = Vector2.ZERO
  turret.player = player
  
  player.add_child(turret)

func on_unequip(_player: Player):
  if turret :
    turret.queue_free()
    turret = null

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(200, 100)).add_animation(load("res://Weapons/Rusty Sword/sword_slash.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 100
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 250
  
  dmg.on_hit.connect(func(_x):
    if turret :
      turret.scraps += dmg.damage
  )
  
  stop_atk(.3)
  set_cooldown(.5)
  
  return [dmg]
