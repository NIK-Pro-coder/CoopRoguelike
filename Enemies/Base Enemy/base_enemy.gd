extends CharacterBody2D

class_name Enemy

enum MOVEMENT_TARGET {
  ALLY,
  NONE
}

const XP_ORB_CLUMP = 1

@export var movement_speed: float = 200.0
@export var movement_target: MOVEMENT_TARGET = MOVEMENT_TARGET.NONE
@export var target_distance = 150
@export var attack_cooldown: float = 2.5
@export var points_for_wave: int = 0
@export var knockback_mult: float = 1

var knockback: Vector2 = Vector2.ZERO

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_cooldown_timer: Timer = $attackCooldown
@onready var healthcomponent: HealthComponent = $healthCoponent
@onready var footstep_particle: GPUParticles2D = %footsteps
@onready var effectcomp: EffectComponent = %effectComponent

var damageAreaScene = load("res://DamageAreas/enemy_damage_area.tscn")
var telegraphScene = preload("res://Telegraphs/generic_telegraph.tscn")

@export var Icon: Sprite2D

var wave_scaling: float = 1
var stat_tracker := StatTracker.new()

func _ready():
  healthcomponent.set_max_hp(int(healthcomponent.max_health * wave_scaling))
  
  damageAreaScene.instantiate()
  
  # These values need to be adjusted for the actor's speed
  # and the navigation layout.
  navigation_agent.path_desired_distance = 4.0
  navigation_agent.target_desired_distance = target_distance
  
  Icon.material = Icon.material.duplicate()

var target: Node2D = null

func recalculateTarget() :
  if movement_target == MOVEMENT_TARGET.NONE :
    target = null
    return
  
  if movement_target == MOVEMENT_TARGET.ALLY :
    var allies = get_tree().get_nodes_in_group("ally")
    
    if len(allies) == 0 :
      target = null
      return
    
    allies.sort_custom(func (a: Node2D, b: Node2D) :
      return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)
    )
    
    target = allies[0]
    return

func set_movement_target(move_target: Vector2):
  navigation_agent.target_position = move_target

func attack(_atk_target: Node2D) :
  pass

func _process(_delta: float) -> void:
  visible = healthcomponent.health > 0 and visible
  
  footstep_particle.emitting = velocity != Vector2.ZERO

  stat_tracker.reset()
  effectcomp.apply_effects(stat_tracker)
  healthcomponent.damage_mult = stat_tracker.DAMAGE_TAKEN_PERCENT

var time_alive := 0.0

func _physics_process(_delta):
  velocity = Vector2.ZERO
  
  time_alive += .05;
  
  Icon.material.set_shader_parameter("progress", time_alive)
  
  healthcomponent.invincible = time_alive <= 2
  
  if time_alive <= 2 :
    return
  
  if !visible :
    return
  
  if knockback != Vector2.ZERO :
    velocity = knockback
    move_and_slide()
    
    knockback.x = move_toward(knockback.x, 0, 10)
    knockback.y = move_toward(knockback.y, 0, 10)
    
    return
  
  if target == null :
    return

  # Now that the navigation map is no longer empty, set the movement target.
  set_movement_target(target.global_position)
  
  if navigation_agent.is_navigation_finished():
    if attack_cooldown_timer.is_stopped() :
      attack_cooldown_timer.start(attack_cooldown)
      attack(target)
    return

  var current_agent_position: Vector2 = global_position
  var next_path_position: Vector2 = navigation_agent.get_next_path_position()

  velocity = current_agent_position.direction_to(next_path_position) * (movement_speed * stat_tracker.SPEED_PERCENT + stat_tracker.SPEED)
  move_and_slide()

var xpOrbScene = preload("res://Xp Orb/xp_orb.tscn")

func on_death() :
  var remain = round(points_for_wave * randf_range(.85, 1.15))
  
  while remain > 0 :
    var v = min(XP_ORB_CLUMP, remain)
    
    remain -= v
    
    var orb: XpOrb = xpOrbScene.instantiate()
    orb.xp_value = v
    orb.global_position = global_position
    
    get_parent().add_child.call_deferred(orb)
  
  queue_free()

func _on_health_coponent_death() -> void:
  on_death()

func _on_recalculate_target_timer_timeout() -> void:
  recalculateTarget()
