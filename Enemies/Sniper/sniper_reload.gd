extends EnemyState

var reloading: bool = false

func process_state(enemy: StateMachineEnemy, _aggro: Node2D) -> void:
  if reloading :
    return
  
  reloading = true
  
  Qol.create_timer(func():
    if !is_instance_valid(enemy) :
      return
    
    reloading = false
    enemy.set_state("follow")
  , 1.5)

func get_state_name() -> String: return "reload"
