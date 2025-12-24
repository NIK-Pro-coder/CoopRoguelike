extends EnemyState

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.set_pathing_target(aggro)
  
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 500 * 500 :
    enemy.set_state("circle")

func get_state_name() -> String: return "follow"
