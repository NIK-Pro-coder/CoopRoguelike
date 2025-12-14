extends Node2D

#class_name Weapon

enum WEAPON_TYPE {
  MELEE_SLASH,
  MELEE_POKE,
  MELEE_SMASH,
}

@export var type: WEAPON_TYPE = WEAPON_TYPE.MELEE_SLASH
@export var damage: int = 5
@export var knockback: float = 100
@export var atk_range: float = 100
@export var texture: Texture2D
@export var weapon_name: String = "Base Weapon"
@export_multiline var weapon_desc: String = ""
@export var enchantability: int = 1

@export_category("Timings")
@export_range(0, 5, .05, "or_greater") var cooldown: float = 1
@export_range(0, 5, .05, "or_greater") var windup: float = 0
@export_range(0.2, 5, .05, "or_greater") var follow_through: float = 0

@onready var cooldownTimer: Timer = $cooldown
@onready var windupTimer: Timer = $windup
@onready var followTimer: Timer = $follow

var enchants: Array[Glyph] = []

var canAttack = true
var isAttacking = false

var damageAreaScene = preload("res://DamageAreas/player_damage_area.tscn")

var attacker: Player

func attack(dir: Vector2) :
  
  attacker = get_parent()
  if not canAttack :
    return
    
  if dir == Vector2.ZERO :
    return

  canAttack = false
  isAttacking = true
  
  if windup == 0 :
    _start_atk(dir)
  else :
    _windup(dir)
    windupTimer.start(windup)

var atk_dir: Vector2

func _start_atk(dir: Vector2) :
  atk_dir = dir

  var areas = _attack(dir)
  
  for i in areas :
    for a in attacker.accessories :
      if a :
        a.on_atk(attacker, i)
  
  if follow_through == 0 :
    _end_atk(dir)
  else :
    followTimer.start(follow_through)

func _end_atk(dir: Vector2) :
  isAttacking = false
  _follow(dir)
  cooldownTimer.start(cooldown)

## Called before the attack starts (aka at windup)
func _windup(dir: Vector2) :
  atk_dir = dir

## Handles the attack's logic
func _attack(dir: Vector2) -> Array[DamageArea] :
  print("Attack with offset: %s" % dir)
  
  return []

## Called after the attack (aka follow through)
func _follow(_dir: Vector2) :
  pass
  
func _on_cooldown_timeout() -> void:
  canAttack = true

func _on_windup_timeout() -> void:
  _start_atk(atk_dir)

func _on_follow_timeout() -> void:
  _end_atk(atk_dir)
