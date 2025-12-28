extends EnemyState

var attacking = false

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  if attacking :
    return
  
  enemy.set_pathing_position(
    aggro.global_position + Vector2.from_angle(
      aggro.global_position.angle_to_point(enemy.global_position) + .1
    ) * (aggro.global_position.distance_to(enemy.global_position) - 25)
  )
  
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 250 * 250 :
    attacking = true
    
    Qol.create_timer(func() :
      if !is_instance_valid(aggro) :
        attacking = false
        return
      
      if !is_instance_valid(enemy) :
        return
      
      var d := enemy.create_atk(Vector2(250, 100), 10)
      d.global_position = enemy.global_position + (aggro.global_position - enemy.global_position).normalized() * 100
      d.rotation = enemy.global_position.angle_to_point(aggro.global_position) + PI / 2.0
      
      enemy.set_pathing_position(
        aggro.global_position + (enemy.global_position - aggro.global_position).normalized() * 500
      )
      
      Qol.create_timer(func(): attacking = false, 1.5)
    )

func get_state_name() -> String: return "approach"
