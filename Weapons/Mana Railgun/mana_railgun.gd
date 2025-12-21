extends Weapon

var particleScene = preload("res://Weapons/Mana Railgun/railgun_particles.tscn")

func change_stats(_player: Player, stats: StatTracker):
  if isCharging :
    stats.SPEED_PERCENT -= .4

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(50, 5000)).add_animation(load("res://Weapons/Rusty Dagger/dagger_poke.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .1
  dmg.global_position = player.global_position + dir * 2500
  dmg.attacker = player
  dmg.piercing = -1
  
  player.knockback = -dir * 400
  
  for i in range(0, 5000, 64) :
    var part: GPUParticles2D = particleScene.instantiate()
    part.emitting = true
    part.global_position = player.global_position + dir * i
    part.rotation = dmg.rotation
    
    player.get_tree().get_root().add_child.call_deferred(part)
    Qol.create_timer(func(): part.queue_free(), .5)
  
  stop_atk(.25)
  set_cooldown(.5)
  
  damage_mult = get_charge_progress()
  
  return [dmg]
