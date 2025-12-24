extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.set_pathing_position(
    aggro.global_position + Vector2.from_angle(aggro.global_position.angle_to_point(enemy.global_position) + .1) * 500
  )
  
  if enemy.global_position.distance_squared_to(aggro.global_position) >= 750 * 750 :
    enemy.set_state("follow")
    
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 350 * 350 :
    enemy.set_state("move_away")
  
  if randf() <= .015 :
    enemy.set_state("move_in")
  
func get_state_name() -> String: return "circle"
