extends Weapon

func spawn_atk(player: Player, dir: Vector2):
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(200, 200)).add_animation(load("res://Weapons/Rusty Mace/mace_slam.tres")).instantiate()
  dmg.visible = false
  dmg.monitorable = false
  dmg.monitoring = false
  dmg.lifetime = .4
  dmg.process_mode = Node.PROCESS_MODE_DISABLED
  
  Qol.create_timer(func():
    dmg.process_mode = Node.PROCESS_MODE_INHERIT
    dmg.visible = true
    dmg.monitorable = true
    dmg.monitoring = true
    dmg.rotation = dir.angle()
    dmg.rotation_degrees += 90
    dmg.global_position = player.global_position + dir * 150
    dmg.attacker = player
    dmg.knockback = dir.normalized() * 300
  , .2)
  
  stop_atk(.6)
  set_cooldown(.85)
  
  return [dmg]
