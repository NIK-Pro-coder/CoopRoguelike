extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.set_pathing_target(aggro)
  
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 150 * 150 :
    enemy.stop_pathing()
    enemy.set_state("explode")

func get_state_name() -> String: return "charge"
