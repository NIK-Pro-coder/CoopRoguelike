extends Enemy

@export var EXPLOSION_FUSE = .5

var exploding = false

func attack(_target: Node2D) :
  if exploding :
    return
  
  exploding = true
  movement_speed = 0
  $explosionTimer.start(EXPLOSION_FUSE)
  
func _on_explosion_timer_timeout() -> void:
  var area: DamageArea = damageAreaScene.instantiate()
  var shape = CollisionShape2D.new()
  
  shape.shape = RectangleShape2D.new()
  (shape.shape as RectangleShape2D).size = Vector2(400, 400)
  shape.debug_color = Color(1, 0, 0, .42)
  
  area.add_child(shape)
  area.attacker = self
  area.global_position = global_position
  area.lifetime = .25
  area.damage = 25
  
  get_tree().get_root().add_child.call_deferred(area)
  $AudioStreamPlayer2D.play()
  visible = false
  
  var part: GPUParticles2D = $explosion.duplicate()
  part.emitting = true
  part.finished.connect(func (): part.queue_free())
  part.global_position = global_position
  
  get_tree().get_root().add_child.call_deferred(part)

func _on_audio_stream_player_2d_finished() -> void:
  queue_free()
