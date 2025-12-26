extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.stat_tracker.SPEED_PERCENT += .25
  
  enemy.set_pathing_position(
    aggro.global_position + (enemy.global_position - aggro.global_position).normalized() * 800
  )
  
  if enemy.global_position.distance_squared_to(aggro.global_position) >= 750 * 750 :
    enemy.set_state("follow")
    
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 350 * 350 :
    enemy.set_state("shoot")

func get_state_name() -> String: return "run_away"
