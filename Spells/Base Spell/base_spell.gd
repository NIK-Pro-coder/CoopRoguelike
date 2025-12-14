extends Node2D

class_name Spell

enum TARGET_TYPES {
  ## Any hostile creature
  ENEMY,
  ## Any ally, this includes players and spawnables
  ALLY,
  ## The caster
  CASTER
}

@export var SPELL_NAME: String = "Base Spell"
@export var SPELL_ICON: Texture2D
## The cooldown between spell uses
@export_range(0.1, 5, .05, "or_greater") var COOLDOWN: float = 1
## The delay between spell usage & effect, also the delay between activations if TARGET_NUM is greater than 1
@export_range(0, 5, .05, "or_greater") var DELAY: float = 0

@export_range(1, 10, 1, "or_greater") var MANA_COST: int = 5

@export_category("Target")
## The spell's max range
@export_range(1, 100, .5, "or_greater") var MAX_RANGE: float = 50
## The amount of possible_targets the spell will hit
@export_range(1, 5, 1, "or_greater") var TARGET_NUM: int = 1
## The type of target the spell will hit, 
@export var TARGET_TYPE: TARGET_TYPES = TARGET_TYPES.ENEMY
## Only has an affect if TARGET_NUM is greater than 1, whether the spell can hit the same target multiple times
@export var ALLOW_SAME_TARGET: bool = false

@onready var cooldownTimer = $cooldownTimer
@onready var delayTimer = $delayTimer

var damageAreaScene = preload("res://DamageAreas/player_damage_area.tscn")

var cast_num = 0
var targets = []

var canUse = true
var hasTargets = false

func getTargets() :
  var possible_targets = []
  
  if TARGET_TYPE == TARGET_TYPES.ENEMY :
    possible_targets = get_tree().get_nodes_in_group("enemy")
  elif TARGET_TYPE == TARGET_TYPES.ALLY :
    possible_targets = get_tree().get_nodes_in_group("ally")
  elif TARGET_TYPE == TARGET_TYPES.CASTER :
    possible_targets = [get_parent()]
  
  possible_targets = possible_targets.filter(func (a: Node2D):
    return a.global_position.distance_squared_to(get_parent().global_position) <= MAX_RANGE * MAX_RANGE
  )

  return possible_targets

func _process(_delta: float) -> void:
  hasTargets = len(getTargets()) > 0

func cast() :
  if !canUse :
    return
  
  cast_num = 0

  var caster_pos = (get_parent() as Player).global_position
  var possible_targets = getTargets()
  
  possible_targets.sort_custom(func (a: Node2D, b: Node2D): return a.global_position.distance_squared_to(caster_pos) < b.global_position.distance_squared_to(caster_pos))
  targets.clear()
  
  # The element at position #0 will always be
  # the caster and since we don't want all
  # spells that target allies to be "self-cast"
  # we move the cater to the end of the array
  if TARGET_TYPE == TARGET_TYPES.ALLY : 
    possible_targets.append(possible_targets.pop_at(0))
  
  for i in range(TARGET_NUM) :
    if ALLOW_SAME_TARGET :
      targets.append(possible_targets[0])
    elif i < len(possible_targets) :
      targets.append(possible_targets[i])
    
  canUse = false
  delayTimer.start(DELAY)

func _cast(pos: Vector2) :
  print("Cast spell at ", pos)

func _on_cooldown_timer_timeout() -> void:
  canUse = true

func _on_delay_timer_timeout() -> void:
  if cast_num >= len(targets) :
    cooldownTimer.start(COOLDOWN)
    return
  
  var target = targets[cast_num]
  
  if !is_instance_valid(target) :
    cooldownTimer.start(COOLDOWN)
    return
  
  _cast((target as Node2D).global_position)
  
  cast_num += 1
  
  delayTimer.start(DELAY)
