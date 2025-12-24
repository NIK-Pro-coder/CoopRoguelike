extends Weapon

var targetScene = preload("res://Weapons/Cosmic Judgement/cosmic_judgement_target.tscn")

func on_charge(player: Player):
  var enemies = player.get_tree().get_nodes_in_group("enemy").filter(func(i):
    var pos = (i as Node2D).global_position
    return (pos - player.global_position).normalized().dot(player.lastMoveDir) >= .8
  )
  
  enemies.sort_custom(func(a: Node2D, b: Node2D):
    return a.global_position.distance_squared_to(player.global_position) < b.global_position.distance_squared_to(player.global_position)
  )
  
  if len(enemies) == 0 :
    return
  
  var enemy: Node2D = enemies[0]
  
  var spr := Sprite2D.new()
  spr.texture = load("res://Weapons/Cosmic Judgement/cosmic_judgement_aim.png")
  spr.global_position = enemy.global_position
  spr.scale = Vector2.ONE * 4
  
  player.get_tree().get_root().add_child.call_deferred(spr)
  
  var l := Line2D.new()
  l.points = [player.global_position, enemy.global_position]
  l.default_color = Color(1, 1, 0)
  l.default_color.a = get_charge_progress()
  l.width = 5
  
  player.get_tree().get_root().add_child.call_deferred(l)
  
  Qol.create_timer(spr.queue_free, .1)
  Qol.create_timer(l.queue_free, .1)
  
  if get_charge_progress() >= 1 :
    var target = targetScene.instantiate()
    target.global_position = enemy.global_position
    target.player = player
    
    player.get_tree().get_root().add_child.call_deferred(target)
    
    if chargeTimer :
      chargeTimer.queue_free()
      chargeTimer = null
    isCharging = false
