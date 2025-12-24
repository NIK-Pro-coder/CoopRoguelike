extends CharacterBody2D
class_name Enemy

var XP_ORB_SCENE: PackedScene = preload("res://Xp Orb/xp_orb.tscn")
var DEBUGGING: bool = true

@export var MAX_HP: int = 100
@export var XP_VALUE: int = 10
@export var SPEED: float = 250

@export var knockback_mult: float = 1.0

@onready var hpComp: HealthComponent = %healthCoponent
@onready var effectComp: EffectComponent = %effectComponent
@onready var sprite: AnimatedSprite2D = %sprite
@onready var navAgent: NavigationAgent2D = %navAgent
@onready var aggroChange: Timer = %aggroChange

var wave_scaling: float = 1.0

var aggro: Node2D = null

var stat_tracker := StatTracker.new()

var knockback := Vector2.ZERO

func _ready() -> void:
  DEBUGGING = DEBUGGING and OS.is_debug_build()
  
  hpComp.set_max_hp(int(MAX_HP * wave_scaling))

func _process(_delta: float) -> void:
  stat_tracker.reset()
  effectComp.apply_effects(stat_tracker)
  
  %hptxt.visible = DEBUGGING
  %hptxt.text = "%s / %s" % [int(hpComp.health), hpComp.max_health]
  
  %aggroDisp.visible = DEBUGGING
  %aggroDisp.text = "Aggro: %s" % [str(aggro.name) if aggro else "None"]
  
  navAgent.debug_enabled = DEBUGGING
  
  velocity = Vector2.ZERO
  
  if knockback :
    velocity = knockback
    knockback *= .9
    if knockback.length() <= 10 :
      knockback = Vector2.ZERO
      
    move_and_slide()
    return
  
  if !navAgent.is_navigation_finished() :
    velocity = (navAgent.get_next_path_position() - global_position).normalized() * (SPEED * stat_tracker.SPEED_PERCENT + stat_tracker.SPEED)
  
  move_and_slide()

func on_death() :
  var remain = round(XP_VALUE * randf_range(.85, 1.15))
  
  while remain > 0 :
    remain -= 1
    
    var orb: XpOrb = XP_ORB_SCENE.instantiate()
    orb.xp_value = 1
    orb.global_position = global_position
    
    get_parent().add_child.call_deferred(orb)
  
  queue_free()

func force_aggro(target: Node2D, time: float) :
  aggro = target
  aggroChange.stop()
  aggroChange.start(time)

func set_pathing_position(pos: Vector2) :
  navAgent.target_position = pos

func set_pathing_target(target: Node2D) :
  if !target :
    return

  set_pathing_position(target.global_position)

func _on_aggro_change_timeout() -> void:
  aggroChange.stop()
  aggroChange.start(.5)
  
  var d: float = -1
  
  for i in get_tree().get_nodes_in_group("ally") :
    var dist = (i as Node2D).global_position.distance_squared_to(global_position)
    
    if d < 0 or dist < d :
      d = dist
      aggro = i
