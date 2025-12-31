extends EnemyState

var aimed: bool = false

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  if aimed :
    return
  
  aimed = true
  
  var t := Qol.create_telegraph(Vector2(5000, 50), 2)
  t.global_position = enemy.global_position + (aggro.global_position - enemy.global_position).normalized() * t.SHAPE_SIZE.x / 2.0
  t.rotation = enemy.global_position.angle_to_point(aggro.global_position)
  
  for i in range(29) :
    Qol.create_timer(func():
      if !is_instance_valid(enemy) or !is_instance_valid(aggro) :
        return
      
      t.global_position = enemy.global_position + (aggro.global_position - enemy.global_position).normalized() * t.SHAPE_SIZE.x / 2.0
      t.rotation = enemy.global_position.angle_to_point(aggro.global_position)
    , i / 20.0 + .1)

  t.telegraph_finished.connect(func():
    t.queue_free()
    
    if !is_instance_valid(enemy) :
      return
    
    var a := enemy.create_atk(t.SHAPE_SIZE, 20)
    a.global_position = t.global_position
    a.rotation = t.rotation
    
    enemy.set_state("reload")
    aimed = false
  )

func get_state_name() -> String: return "aim"
