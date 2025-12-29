extends EnemyState

func get_enemy_to_heal(enemy: StateMachineEnemy) :
  var all_enemies = enemy.get_tree().get_nodes_in_group("enemy")
  all_enemies.erase(enemy)
  all_enemies = all_enemies.filter(func(x: Enemy): return x.hpComp.health < x.hpComp.max_health)
  all_enemies.sort_custom(func(a: Enemy, b: Enemy): return a.global_position.distance_squared_to(enemy.global_position) < b.global_position.distance_squared_to(enemy.global_position))

  if len(all_enemies) == 0 :
    return null

  return all_enemies[0]

var can_heal: bool = true

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 300 * 300 :
    enemy.set_state("run_away")
    return
  
  var to_heal: Enemy = get_enemy_to_heal(enemy)
  
  if !to_heal :
    return
  
  enemy.set_pathing_position(
    to_heal.global_position - (aggro.global_position - to_heal.global_position).normalized() * 350
  )
  
  if can_heal and enemy.global_position.distance_squared_to(to_heal.global_position) <= 400 * 400 :
    to_heal.hpComp.healDmg(5)
    
    var l := Line2D.new()
    l.points = [enemy.global_position, to_heal.global_position]
    l.z_index = -1
    l.default_color = Color(0, 1, 0, .5)
    
    enemy.get_tree().get_root().add_child.call_deferred(l)
    Qol.create_timer(l.queue_free, .2)
    
    can_heal = false
    
    Qol.create_timer(func(): can_heal = true, 1)

func get_state_name() -> String: return "heal"
