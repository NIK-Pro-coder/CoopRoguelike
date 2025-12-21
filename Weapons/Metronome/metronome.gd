extends Weapon

var barScene = preload("res://Weapons/Metronome/metronome_bar.tscn")
var metronomeBar: ProgressBar
var metronomeTimer: Timer

func on_equip(player: Player):
  metronomeBar = barScene.instantiate()
  metronomeBar.position = Vector2(-72, -56)
  player.add_child(metronomeBar)
  
  metronomeTimer = Qol.create_timer(func(): pass, 1)
  metronomeTimer.one_shot = false
  
  metronomeBar.progressTimer = metronomeTimer

func on_unequip(_player: Player):
  if metronomeBar :
    metronomeBar.queue_free()
    metronomeBar = null
  
  if metronomeTimer :
    metronomeTimer.queue_free()
    metronomeTimer = null

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(200, 100)).add_animation(load("res://Weapons/Rusty Sword/sword_slash.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 100
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 250
  
  damage_mult = 2.0 if metronomeTimer.time_left <= .3 else .5
  Qol.display_string(player.global_position - Vector2(0, 50), "On-beat!" if damage_mult == 2.0 else "Off-beat", .25)
  
  stop_atk(.1)
  set_cooldown(.25)
  
  return [dmg]
