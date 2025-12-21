extends Area2D

var active = true

func _ready() -> void:
  %sprite.material = %sprite.material.duplicate()

func _process(_delta: float) -> void:
  %sprite.material.set_shader_parameter("active", active and len(get_tree().get_nodes_in_group("enemy")) > 0)

  %particles.emitting = active and len(get_tree().get_nodes_in_group("enemy")) > 0

func findHpComp(from: Node) :
  if from is HealthComponent :
    return from
  
  for i in from.get_children() :
    var r = findHpComp(i)
    
    if r is HealthComponent :
      return r
  
  return null

var master: Player

func _on_dot_timeout() -> void:
  if !active :
    return
  
  if len(get_tree().get_nodes_in_group("enemy")) == 0 :
    return
  
  for i in get_overlapping_bodies() :
    var hp: HealthComponent = findHpComp(i)
    
    if not hp :
      continue
    
    if i is Player or i is PlayerSummon :
      if i == master :
        hp.healDmg(1)
      else :
        hp.healDmg(2)
