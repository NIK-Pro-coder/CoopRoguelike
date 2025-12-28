extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  
  var lm := Vector2.ZERO
  
  if "lastMoveDir" in aggro and aggro["lastMoveDir"] :
    lm = aggro["lastMoveDir"].normalized()
  else :
    lm = Vector2(0, 1)
    
  var perp = Vector2(lm.y, -lm.x)
  var front = (aggro.global_position - enemy.global_position).normalized()
  
  if (-lm).dot(front) <= -.95 :
    enemy.stop_pathing()
    if randf() <= .5 and enemy.global_position.distance_squared_to(aggro.global_position) >= 250 * 250 :
      enemy.set_state("attack")
    return
  
  var d = perp.dot(front)
  
  if d > 0 :
    enemy.set_pathing_position(
      aggro.global_position + Vector2.from_angle(aggro.global_position.angle_to_point(enemy.global_position) + .1) * 600
    )
  else :
    enemy.set_pathing_position(
      aggro.global_position + Vector2.from_angle(aggro.global_position.angle_to_point(enemy.global_position) - .1) * 600
    )

func get_state_name() -> String: return "sneak_up"
