extends Area2D

@onready var icon: Sprite2D = %Icon

var player: Player

func _ready() -> void:
  get_tree().paused = true
  
  get_viewport().get_camera_2d().get_parent().locked = true
  get_viewport().get_camera_2d().get_parent().lock_pos = global_position
  get_viewport().get_camera_2d().get_parent().lock_zoom = .5
  
  icon.material = icon.material.duplicate()

var circle_progress: float = 0.0
var line_progress: float = 0.0

var spin_vel: float = 0.0
var circle_spin: float = 0.0

func _process(_delta: float) -> void:
  circle_progress += 0.005
  
  if spin_vel >= .1 :
    line_progress = min(1, line_progress + .001)
  elif circle_progress >= 1 :
    line_progress = min(.5, line_progress + .01)
  
  if line_progress >= .5 :
    spin_vel = min(.15, spin_vel + .001)
  
  if line_progress >= 1 :
    get_tree().paused = false
    
    for i in get_tree().get_nodes_in_group("enemy") :
      if (i as Node2D).global_position.distance_to(global_position) <= 440 :
        if i is Enemy :
          i.healthcomponent.dealDmg(500)
          player.potion_charge_progress += 500
          player.damageDone += 500
        elif i is Boss :
          i.HpComp.dealDmg(500)
          player.potion_charge_progress += 500
          player.damageDone += 500
    queue_free()
  
    get_viewport().get_camera_2d().get_parent().locked = false
    get_viewport().get_camera_2d().get_parent() .addScreenshake(1000)
  
  circle_spin += spin_vel
  
  (icon.material as ShaderMaterial).set_shader_parameter("circle_progress", circle_progress)
  (icon.material as ShaderMaterial).set_shader_parameter("line_progress", line_progress)
  (icon.material as ShaderMaterial).set_shader_parameter("circle_spin", circle_spin)
