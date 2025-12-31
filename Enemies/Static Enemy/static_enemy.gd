extends CharacterBody2D
class_name Enemy

var XP_ORB_SCENE: PackedScene = preload("res://Xp Orb/xp_orb.tscn")
var DEBUGGING: bool = false

@export var MAX_HP: int = 100
@export var XP_VALUE: int = 10
@export var SPEED: float = 250
@export var CAN_ENRAGE: bool = true

@export var knockback_mult: float = 1.0

@onready var hpComp: HealthComponent = %healthCoponent
@onready var effectComp: EffectComponent = %effectComponent
@onready var sprite: AnimatedSprite2D = %sprite
@onready var navAgent: NavigationAgent2D = %navAgent
@onready var aggroChange: Timer = %aggroChange
@onready var enragePart: GPUParticles2D = %enemy_enrage_part

var wave_scaling: float = 1.0

var aggro: Node2D = null

var stat_tracker := StatTracker.new()

var knockback := Vector2.ZERO
var knockback_taken: float = 0
var max_knockback: float = 0
var enraged: bool = false

func _ready() -> void:
  DEBUGGING = DEBUGGING and OS.is_debug_build()
  
  hpComp.set_max_hp(int(MAX_HP * wave_scaling))
  
  max_knockback = MAX_HP * wave_scaling
  %knockbackBar.max_value = max_knockback
  
  sprite.material = sprite.material.duplicate()

func handle_logic() :
  pass
  
func create_atk(size: Vector2, base_dmg: int, anim: SpriteFrames = null) -> DamageArea :
  var atk := Qol.create_atk(true).set_rect_shape(size)
  
  if anim :
    atk.add_animation(anim)
  
  var d := atk.instantiate()
  d.damage = base_dmg * stat_tracker.DAMAGE_PERCENT + stat_tracker.DAMAGE
  
  return d

func _process(_delta: float) -> void:
  stat_tracker.reset()
  effectComp.apply_effects(stat_tracker)
  
  (sprite.material as ShaderMaterial).set_shader_parameter("enraged", enraged)
  
  if enraged :
    stat_tracker.DAMAGE_PERCENT += .25
    stat_tracker.SPEED_PERCENT += .25
    knockback_mult = 0
  else :
    knockback_mult = 1
  
  if CAN_ENRAGE and !enraged and knockback_taken >= max_knockback :
    knockback_taken = max_knockback
    enraged = true
    enragePart.emitting = true
  if enraged and knockback_taken <= 0 :
    knockback_taken = 0
    enraged = false
  
  %hptxt.visible = DEBUGGING
  %hptxt.text = "%s / %s" % [int(hpComp.health), hpComp.max_health]
  
  %aggroDisp.visible = DEBUGGING
  %aggroDisp.text = "Aggro: %s" % [str(aggro.name) if aggro else "None"]
  
  %knockbackBar.visible = DEBUGGING
  %knockbackBar.value = knockback_taken
  
  navAgent.debug_enabled = DEBUGGING
  
  if knockback :
    velocity = knockback
    knockback *= .9
    if knockback.length() <= 10 :
      knockback = Vector2.ZERO
      
    move_and_slide()
    return
  
  handle_logic()
  
  if !navAgent.is_navigation_finished() :
    var new_vel = (navAgent.get_next_path_position() - global_position).normalized() * (SPEED * stat_tracker.SPEED_PERCENT + stat_tracker.SPEED)
  
    if navAgent.avoidance_enabled :
      navAgent.set_velocity(new_vel)
    else :
      _on_nav_agent_velocity_computed(new_vel)
    
  if aggro :
    if aggro.global_position.x < global_position.x :
      sprite.flip_h = true
    elif aggro.global_position.x > global_position.x :
      sprite.flip_h = false

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

func stop_pathing() :
  set_pathing_position(global_position)

func set_pathing_position(pos: Vector2, force: bool = false) :
  if !force and pos.distance_squared_to(Vector2.ZERO) >= 2000 * 2000 :
    navAgent.target_position = pos - pos.normalized() * 250
    return
  
  navAgent.target_position = pos

func set_pathing_target(target: Node2D, force: bool = false) :
  if !target :
    return

  set_pathing_position(target.global_position, force)

func get_closest_ally() :
  var d: float = -1
  var a: Node2D
  
  for i in get_tree().get_nodes_in_group("ally") :
    var dist = (i as Node2D).global_position.distance_squared_to(global_position)
    
    if d < 0 or dist < d :
      d = dist
      a = i
  
  return a
  
func get_closest_enemy() :
  var d: float = -1
  var a: Node2D
  
  for i in get_tree().get_nodes_in_group("enemy") :
    var dist = (i as Node2D).global_position.distance_squared_to(global_position)
    
    if i != self and (d < 0 or dist < d) :
      d = dist
      a = i
  
  return a

func change_aggro() :
  aggro = get_closest_ally()

func _on_aggro_change_timeout() -> void:
  aggroChange.stop()
  aggroChange.start(.5)
  change_aggro()

func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
  velocity = safe_velocity

func _on_health_coponent_knocked_back(amt: Vector2) -> void:
  knockback_taken += amt.length() / 5 * (-1 if enraged else 1)
