extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.set_pathing_position(
    enemy.global_position - (aggro.global_position - enemy.global_position).normalized() * 150
  )
  
  if enemy.global_position.distance_squared_to(aggro.global_position) >= 400 * 400 :
    enemy.set_state("heal")

func get_state_name() -> String: return "run_away"
