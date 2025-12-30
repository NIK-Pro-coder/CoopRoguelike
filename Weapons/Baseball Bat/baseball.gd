extends CharacterBody2D

var knockback := Vector2.ZERO

func _physics_process(_delta: float) -> void:
  if  move_and_slide() :
    var normal := get_last_slide_collision().get_normal()
    var perp_normal = Vector2(normal.y, -normal.x)
    
    velocity = velocity.rotated(-2.0 * perp_normal.angle_to(velocity)) * .75
    move_and_slide()

func _on_health_coponent_knocked_back(amt: Vector2) -> void:
  Qol.addHitstop(.1)
  velocity = amt * 7.0
  
  var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
  enemies = enemies.filter(func(x: Enemy) :
    return (x.global_position - global_position).normalized().dot(amt.normalized()) >= .8
  )
  enemies.sort_custom(func(a: Enemy, b: Enemy): return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
  
  if len(enemies) == 0 :
    return
  
  var enemy: Enemy = enemies[0]
  
  print(enemy)

func _ready() -> void:
  $healthCoponent.damage_mult = 0
