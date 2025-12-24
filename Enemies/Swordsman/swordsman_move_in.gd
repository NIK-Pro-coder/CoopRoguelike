extends EnemyState

var has_attacked = false

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  print(has_attacked)
  
  if has_attacked :
    enemy.set_pathing_position(enemy.global_position)
  else :
    enemy.set_pathing_target(aggro)
  
  if !has_attacked and enemy.global_position.distance_squared_to(aggro.global_position) <= 200 * 200 :
    has_attacked = true
    
    var d: DamageArea = Qol.create_atk(true).set_rect_shape(Vector2(100, 250)).instantiate()
    d.global_position = enemy.global_position + (aggro.global_position - enemy.global_position).normalized() * 150
    d.rotation = enemy.global_position.angle_to_point(aggro.global_position)
    d.damage = 10
    d.visible = false
    d.monitoring = false
    d.monitorable = false
    d.lifetime = .5
    
    Qol.create_timer(func(): 
      enemy.set_state("move_away")
      
      d.visible = true
      d.monitoring = true
      d.monitorable = true
      
      has_attacked = false
    , .25)

func get_state_name() -> String: return "move_in"
