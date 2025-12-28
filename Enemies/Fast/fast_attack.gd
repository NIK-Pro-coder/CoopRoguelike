extends EnemyState

var attacked := false

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  if attacked :
    return
  
  enemy.set_pathing_target(aggro, true)

  if enemy.global_position.distance_squared_to(aggro.global_position) <= 150 * 150 :
    attacked = true
    enemy.stop_pathing()
    
    Qol.create_timer(func():
      if !is_instance_valid(enemy) :
        return
        
      enemy.set_state("sneak_up")
      attacked = false
      
      if !is_instance_valid(aggro) :
        return
      
      var d := enemy.create_atk(Vector2(250, 100), 5)
      d.global_position = enemy.global_position + (aggro.global_position - enemy.global_position).normalized() * 50
      d.rotation = enemy.global_position.angle_to_point(aggro.global_position)
    , .5)

func get_state_name() -> String: return "attack"
