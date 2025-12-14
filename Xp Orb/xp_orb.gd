extends CharacterBody2D

class_name XpOrb

@export var xp_value = 0

func _ready() -> void:
  velocity.x = randf_range(-1, 1)
  velocity.y = randf_range(-1, 1)
  
  velocity = velocity.normalized() * randi_range(0, 1000)

var speed = 0

func _process(_delta: float) -> void:
  var p: Player = null
  var dist = 0
  
  for i in get_tree().get_nodes_in_group("player") :
    var d = (i as Player).global_position.distance_squared_to(global_position)
    
    if p == null or d < dist :
      dist = d
      p = i
  
  if p :
    velocity += (p.global_position - global_position).normalized() * speed
    speed += 5
  
  velocity.x = move_toward(velocity.x, 0, speed / 5.0)
  velocity.y = move_toward(velocity.y, 0, speed / 5.0)
  
  move_and_slide()

func _on_area_2d_body_entered(_body: Node2D) -> void:
  var xp_manager: XpManager = get_tree().get_root().get_node("/root/main/CanvasLayer/xpManager")

  if xp_manager :
    xp_manager.xp += xp_value

  for i in get_tree().get_nodes_in_group("player") :
    (i as Player).mana += (i as Player).get_actual_stat("mana_gain") * xp_value
    (i as Player).mana = min((i as Player).get_actual_stat("max_mana"), (i as Player).mana)
  
  $AudioStreamPlayer2D.play()
  visible = false

func _on_audio_stream_player_2d_finished() -> void:
  queue_free()
