extends Weapon

var aoeScene = preload("res://Weapons/Flute/flute_aoe.tscn")
var aoe: Area2D

func on_equip(player: Player):
  if aoe :
    aoe.queue_free()
    aoe = null
    
  aoe = aoeScene.instantiate()
  aoe.master = player
  player.add_child(aoe)

func on_unequip(_player: Player):
  if aoe :
    aoe.queue_free()
    aoe = null

var activate_timer: Timer

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var tex := AtlasTexture.new()
  tex.atlas = load("res://Weapons/Rusty Sword/sword-slash.png")
  tex.region = Rect2(128, 0, 64, 32)
  
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(50, 150)).add_sprite(tex).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 125
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 150
  
  aoe.active = false
  if activate_timer :
    activate_timer.queue_free()
    activate_timer = null
  
  activate_timer = Qol.create_timer(func(): if aoe: aoe.active = true, .7)
  
  stop_atk(.1)
  set_cooldown(.5)
  
  return [dmg]
