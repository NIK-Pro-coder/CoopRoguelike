extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.stat_tracker.SPEED_PERCENT += .25
  
  enemy.set_pathing_position(
    aggro.global_position + (enemy.global_position - aggro.global_position).normalized() * 750
  )
  
  if enemy.global_position.distance_squared_to(aggro.global_position) >= 500 * 500 :
    enemy.set_state("follow")

func get_state_name() -> String: return "run_away"
