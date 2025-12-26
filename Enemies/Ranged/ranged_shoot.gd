extends EnemyState

var shotScene = preload("res://Enemies/Ranged/ranged_enemy_shot.tscn")
var hasShot = false

func process_state(enemy: StateMachineEnemy, aggro: Node2D) -> void:
  if !hasShot :
    hasShot = true
    var s: DamageArea = shotScene.instantiate()
    s.global_position = enemy.global_position
    s.direction = (aggro.global_position - enemy.global_position).normalized() * 10
    s.rotation = enemy.global_position.angle_to_point(aggro.global_position)

    enemy.get_tree().get_root().add_child.call_deferred(s)
    
    Qol.create_timer(func(): hasShot = false, 1)

  if enemy.global_position.distance_squared_to(aggro.global_position) >= 950 * 950 :
    enemy.set_state("follow")
    
  if enemy.global_position.distance_squared_to(aggro.global_position) <= 650 * 650 and enemy.global_position.distance_squared_to(aggro.global_position) >= 450 * 450 :
    enemy.set_state("run_away")

func get_state_name() -> String: return "shoot"
