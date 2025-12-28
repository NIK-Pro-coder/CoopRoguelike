extends EnemyState

var exploded = false

var partScene = preload("res://Enemies/Creeper/creeper_explode_part.tscn")
var telegraph: GenericTelegraph
var startExplode: Vector2

func process_state(enemy: StateMachineEnemy, _aggro: Node2D) -> void:
  if startExplode and enemy.global_position != startExplode :
    if telegraph :
      telegraph.queue_free()
      telegraph = null
    
    exploded = true
    Qol.create_timer(func(): exploded = false, .5)
    enemy.set_state("charge")
    startExplode = Vector2.ZERO
    return
  
  if exploded :
    return
  
  startExplode = enemy.global_position
  
  exploded = true
  
  telegraph = Qol.create_telegraph(Vector2(500, 500), .35)
  telegraph.global_position = enemy.global_position
  telegraph.telegraph_finished.connect(func():
    if is_instance_valid(enemy) :
      var d := enemy.create_atk(telegraph.SHAPE_SIZE, 25)
      d.global_position = telegraph.global_position
      
      var p: GPUParticles2D = partScene.instantiate()
      p.global_position = telegraph.global_position
      enemy.get_tree().get_root().add_child.call_deferred(p)
      
      Qol.create_timer(p.queue_free, p.lifetime)
      
      enemy.queue_free()
      
    telegraph.queue_free()
    telegraph = null
  )

func get_state_name() -> String: return "explode"
