extends Resource
class_name EnemyState

func get_state_name() -> String :
  return "STATE_NULL"

@warning_ignore("unused_parameter")
func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void :
  pass
