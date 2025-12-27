extends EnemyState

var exploded = false

func process_state(enemy: StateMachineEnemy, _aggro: Node2D) -> void:
  if exploded :
    return
  
  exploded = true
  
  var t := Qol.create_telegraph(Vector2(500, 500), .25)
  t.global_position = enemy.global_position
  t.telegraph_finished.connect(func():
    enemy.queue_free()
    t.queue_free()
    
    var d := Qol.create_atk(true).set_rect_shape(t.SHAPE_SIZE).instantiate()
    d.damage = 25
    d.global_position = t.global_position
  )

func get_state_name() -> String: return "explode"
