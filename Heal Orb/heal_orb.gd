extends CharacterBody2D

class_name HealOrb

@export var heal_amt = 0

func _ready() -> void:
  velocity.x = randf_range(-1, 1)
  velocity.y = randf_range(-1, 1)
  
  velocity = velocity.normalized() * randi_range(0, 1000)

var speed = 10

func _process(_delta: float) -> void:
  var p: Player
  var dist = 0
  
  for i in get_tree().get_nodes_in_group("player") :
    if not "ally" in i.get_groups() :
      continue
    
    var health: HealthComponent = findHealthComponent(i)
    
    if !health or health.health <= 0 or health.health >= health.max_health :
      continue
    
    var d = health.health
    
    if p == null or d < dist :
      dist = d
      p = i
  
  if p :
    velocity += (p.global_position - global_position).normalized() * speed
    speed += 1
  
  velocity.x = move_toward(velocity.x, 0, speed / 2)
  velocity.y = move_toward(velocity.y, 0, speed / 2)
  
  move_and_slide()

func findHealthComponent(from: Node2D) :
  for i in from.get_children() :
    if i is HealthComponent : return i
    
    if not i is Node2D :
      continue
    
    var ret = findHealthComponent(i)
    if ret is HealthComponent : return ret

  return null

func _on_area_2d_body_entered(body: Node2D) -> void:
  var health: HealthComponent = findHealthComponent(body)
  
  if health :
    health.healDmg(heal_amt)
  
  queue_free()

func _on_timer_timeout() -> void:
  queue_free()
