extends CharacterBody2D

@onready var dmg: DamageArea = %dmg
@onready var trail: Line2D = %trail

var player: Player

var speed_cap: float = 0
var knockback := Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO

func calculate_damage(vel: Vector2) -> float :
  return vel.length() / 50

func _ready() -> void:
  $healthCoponent.damage_mult = 0
  dmg.attacker = self

func _physics_process(delta: float) -> void:
  var p := trail.points
  p.append(global_position)
  if len(p) > 25 :
    p.remove_at(0)
  trail.points = p
  trail.global_position = Vector2.ZERO
  
  if acceleration :
    velocity += acceleration * delta
  else :
    velocity += (player.global_position - global_position).normalized() * 350 * delta
  velocity = velocity * .99
  velocity = velocity.normalized() * min(speed_cap, velocity.length())
  
  dmg.damage = (calculate_damage(velocity) if acceleration else 0.0)
  dmg.knockback = velocity if acceleration else Vector2.ZERO
  
  if move_and_slide() :
    var normal := get_last_slide_collision().get_normal()
    var perp_normal = Vector2(normal.y, -normal.x)
    
    velocity = velocity.rotated(-2.0 * perp_normal.angle_to(velocity)) * .75
    move_and_slide()
    acceleration = Vector2.ZERO

var accel: float = 5

func _on_health_coponent_knocked_back(amt: Vector2) -> void:
  Qol.addHitstop(.1)
  velocity = amt * 7.0 + player.velocity
  speed_cap = velocity.length()
  
  var enemies = get_tree().get_nodes_in_group("enemy")
  enemies = enemies.filter(func(x) :
    return (x.global_position - global_position).normalized().dot(amt.normalized()) >= .8
  )
  enemies.sort_custom(func(a, b): return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
  
  if len(enemies) == 0 :  
    var bosses = get_tree().get_nodes_in_group("boss")
    bosses = bosses.filter(func(x) :
      return (x.global_position - global_position).normalized().dot(amt.normalized()) >= .8
    )
    bosses.sort_custom(func(a, b): return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))

    if len(bosses) == 0 :
      return
    
    enemies = bosses
  
  var enemy: Node2D = enemies[0]
  
  var A: Vector2 = global_position
  var B: Vector2 = enemy.global_position
  
  var v: Vector2 = velocity
  
  var vprime: Vector2 = Vector2.UP * v.length()
  
  var delta_angle = v.angle_to(vprime)
  
  var Bprime: Vector2 = (B - A).rotated(delta_angle)
  
  var t := Bprime.y / vprime.y
  
  acceleration = (Vector2.RIGHT * 2 * Bprime.x / (t * t)).rotated(-delta_angle)

func _on_dmg_on_hit(_body: Node2D) -> void:
  player.potion_charge_progress += dmg.damage / 2.0
