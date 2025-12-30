extends Weapon

var ballScene = preload("res://Weapons/Baseball Bat/baseball.tscn")
var ball: CharacterBody2D

func on_equip(player: Player):
  if ball :
    ball.queue_free()
    ball = null
  
  ball = ballScene.instantiate()
  ball.global_position = player.global_position
  
  player.get_tree().get_root().add_child.call_deferred(ball)

func on_unequip(_player: Player):
  if ball :
    ball.queue_free()
    ball = null

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(200, 100)).add_animation(load("res://Weapons/Rusty Sword/sword_slash.tres")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * 100
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 250
  
  stop_atk(.25)
  set_cooldown(1)
  
  return [dmg]
