extends Area2D

class_name ReviveTotem

@export var player_to_res: Player

var progress = 0

@onready var bar: TextureProgressBar = %progress
@onready var icon: Sprite2D = $Icon

func _ready() -> void:
  icon.material = icon.material.duplicate()
  bar.material = bar.material.duplicate()

func _process(_delta: float) -> void:
  if player_to_res :
    icon.material.set_shader_parameter("hue_shift", player_to_res.MAIN_COLOR)
    (bar.material as ShaderMaterial).set_shader_parameter("hue_shift", player_to_res.MAIN_COLOR)
  (bar.material as ShaderMaterial).set_shader_parameter("revive_progress", progress / bar.max_value)
  
  var ressing = false
  
  for i in get_overlapping_bodies() :
    if not i is Player :
      continue
    
    if i == player_to_res :
      continue
    
    var device = (i as Player).DEVICE_ID
    
    if Input.is_joy_button_pressed(device, JOY_BUTTON_Y) if device >= 0 else Input.is_action_pressed("k_revive") :
      ressing = true
      break

  if ressing :
    progress += .4
  elif progress > 0 :
    progress -= .1
  
  if progress >= 100 :
    if player_to_res :
      player_to_res.revive(global_position)
    
    queue_free()
    
    for i in get_overlapping_bodies() :
      if not i is Player :
        continue
      
      if i == player_to_res :
        continue
      
      (i as Player).timesRevived += 1

  #bar.value = progress
