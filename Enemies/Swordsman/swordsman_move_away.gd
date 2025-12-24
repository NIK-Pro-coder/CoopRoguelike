extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.set_pathing_position(
    aggro.global_position + (enemy.global_position - aggro.global_position).normalized() * 550
  )
  
  if enemy.global_position.distance_squared_to(aggro.global_position) >= 500 * 500 :
    enemy.set_state("circle")

func get_state_name() -> String: return "move_away"
