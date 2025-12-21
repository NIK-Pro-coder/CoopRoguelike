extends CharacterBody2D
class_name PlayerSummon

enum SummonTarget {
  ENEMY = 0,
  PLAYERS = 1,
  NONE = 2,
}

@export var TARGET: SummonTarget = SummonTarget.ENEMY
@export var TARGET_DISTANCE: float = 125
@export var SPEED: float = 550
@export var ACTION_COOLDOWN: float = 1.0

@onready var navigation_agent: NavigationAgent2D = %nav_agent
@onready var act_cooldown: Timer = %action_cooldown
@onready var effectcomp: EffectComponent = %effectComponent

var stat_changes := StatTracker.new()

@onready var healthcomponent: HealthComponent = %healthCoponent

var master: Player

var target: Node2D

func _process(_delta: float) -> void:
  stat_changes.reset()
  effectcomp.apply_effects(stat_changes)

func _ready() -> void:
  navigation_agent.path_desired_distance = 4.0
  navigation_agent.target_desired_distance = TARGET_DISTANCE

func do_action(_action_target: Vector2) :
  pass

func get_default_target() :
  return master

func recalculate_target() :
  if TARGET == SummonTarget.NONE :
    return
  
  if TARGET == SummonTarget.PLAYERS :
    var allies = get_tree().get_nodes_in_group("ally")
    
    if len(allies) == 0 :
      target = get_default_target()
      return
    
    allies.sort_custom(func (a: Node2D, b: Node2D) :
      return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)
    )
    
    target = allies[0]
    return
  
  var enemies = get_tree().get_nodes_in_group("enemy")
  
  if len(enemies) == 0 :
    target = get_default_target()
    return
  
  enemies.sort_custom(func (a: Node2D, b: Node2D) :
    return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)
  )
  
  target = enemies[0]
  return

func handle_movement() :
  var current_agent_position: Vector2 = global_position
  var next_path_position: Vector2 = navigation_agent.get_next_path_position()

  velocity = current_agent_position.direction_to(next_path_position) * (SPEED * stat_changes.SPEED_PERCENT + stat_changes.SPEED)
  move_and_slide()

func _physics_process(_delta: float) -> void:
  if master.healtcomponent.health <= 0 :
    remove_from_group("ally")
    return
  add_to_group("ally")
  
  if target == null :
    return
    
  navigation_agent.target_position = target.global_position
  
  if navigation_agent.is_navigation_finished():
    if act_cooldown.is_stopped() and (target != get_default_target() or TARGET == SummonTarget.PLAYERS) :
      do_action(navigation_agent.target_position)
      act_cooldown.start(ACTION_COOLDOWN)
    return
  
  handle_movement()

func _on_recalc_target_timeout() -> void:
  recalculate_target()

signal died

func _on_health_coponent_death() -> void:
  died.emit()
  queue_free()
