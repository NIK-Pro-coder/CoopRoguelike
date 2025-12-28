extends EnemyState

var has_attacked = false

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  enemy.stat_tracker.SPEED_PERCENT += .5
  
  if has_attacked :
    enemy.set_pathing_position(enemy.global_position)
  else :
    enemy.set_pathing_target(aggro, true)
  
  if !has_attacked and enemy.global_position.distance_squared_to(aggro.global_position) <= 200 * 200 :
    has_attacked = true
    
    var d: DamageArea = enemy.create_atk(Vector2(250, 100), 10, load("res://Weapons/Rusty Sword/sword_slash.tres"))
    d.global_position = enemy.global_position + (aggro.global_position - enemy.global_position).normalized() * 150
    d.rotation = enemy.global_position.angle_to_point(aggro.global_position) + PI / 2.0
    d.visible = false
    d.process_mode = Node.PROCESS_MODE_DISABLED
    d.monitoring = false
    d.monitorable = false
    d.lifetime = .5
    
    Qol.create_timer(func(): 
      Qol.create_timer(func() :
        if enemy :
          enemy.set_state("move_away")
        
        has_attacked = false
      , .25)
      
      d.visible = true
      d.monitoring = true
      d.monitorable = true
      d.process_mode = Node.PROCESS_MODE_INHERIT
    , .25)

func get_state_name() -> String: return "move_in"
