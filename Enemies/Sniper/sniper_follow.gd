extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.set_pathing_target(aggro)
  
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 1500 * 1500 :
    enemy.set_state("aim")
    enemy.force_aggro(aggro, 2)
    enemy.stop_pathing()
    
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 500 * 500 :
    enemy.set_state("run_away")

func get_state_name() -> String: return "follow"
