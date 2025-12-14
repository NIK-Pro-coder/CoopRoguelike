extends Node2D

class_name HealthComponent

@onready var particle: GPUParticles2D = $hiteffect

@export var DISPLAY_BAR: ProgressBar

@export var max_health: int = 100
var health = 0
var shield = 0

func _process(delta: float) -> void:
  if DISPLAY_BAR :
    DISPLAY_BAR.max_value = max_health
  
  for i in iframes.keys() :
    iframes[i] -= delta
    if iframes[i] <= 0 :
      iframes.erase(i)

func revive() :
  health = max_health
  updateBar()

var invincible = false

var stylebox_bg: StyleBoxFlat = preload("res://Components/Health Component/stylebox_bg.tres")
var stylebox_hp: StyleBoxFlat = preload("res://Components/Health Component/stylebox_hp.tres")
var stylebox_shield: StyleBoxFlat = preload("res://Components/Health Component/stylebox_shield.tres")

func updateBar() :
  if not DISPLAY_BAR :
    return
  
  DISPLAY_BAR.value = health if shield == 0 else shield
  DISPLAY_BAR.max_value = max_health
  DISPLAY_BAR.visible = health < max_health or shield > 0
  if shield > 0 :
    DISPLAY_BAR.add_theme_stylebox_override("background", stylebox_hp.duplicate())
    DISPLAY_BAR.add_theme_stylebox_override("fill", stylebox_shield.duplicate())
  else :
    DISPLAY_BAR.add_theme_stylebox_override("background", stylebox_bg.duplicate())
    DISPLAY_BAR.add_theme_stylebox_override("fill", stylebox_hp.duplicate())

func _ready() -> void:
  health = max_health
  
  updateBar()

signal death
signal damaged(amt: int)
signal healed(amt: int)

var damageNumScene = preload("res://Damage Num/damage_num.tscn")

func addScreenshake(amt) :
  var camera = get_tree().get_root().get_node("main/maincamera")
  
  (camera as MainCamera).addScreenshake(amt)

func spawnDamageNum(amt: int) :
  var dmgNum: DamageNum = damageNumScene.instantiate()
  dmgNum.DAMAGE = amt
  dmgNum.global_position = get_parent().global_position
  get_tree().get_root().add_child.call_deferred(dmgNum)
  
  if amt > 0 :
    addScreenshake(amt)

func healDmg(amt: int) :
  if amt < 0 :
    return dealDmg(-amt)
  
  if health >= max_health :
    return
  
  health += amt
  health = min(health, max_health)
  
  updateBar()
  spawnDamageNum(-amt)
  
  emit_signal("healed", amt)

func set_max_hp(amt: int):
  # old_hp / old_max_hp = new_hp / new_max_hp
  # (old_hp * new_max_hp) / old_max_hp = new_hp
  # new_hp = old_hp * (new_max_hp / old_max_hp)
  
  health = int(float(health) * float(amt) / float(max_health))
  
  max_health = amt
  
  if health > max_health :
    health = max_health

var damage_mult: float = 1

func add_shield(amt: int) :
  shield = min(max_health, shield+amt)
  updateBar()

func dealDmg(amt: int) :
  if amt < 0 :
    return healDmg(-amt)
  
  if health <= 0 :
    return
  
  if invincible :
    return
  
  var part: GPUParticles2D = particle.duplicate()
  part.global_position = (get_parent() as Node2D).global_position
  part.emitting = true
  get_tree().get_root().add_child.call_deferred(part)
  
  $AudioStreamPlayer2D.play()
  
  var dmg_taken = max(0, amt * damage_mult)
  
  emit_signal("damaged", round(amt * damage_mult))
  
  if dmg_taken <= 0 :
    return
  
  if shield >= dmg_taken :
    shield -= dmg_taken
    dmg_taken = 0
  else :
    shield = 0
    dmg_taken -= shield
  
  health -= round(dmg_taken)
  health = max(health, 0)
  
  updateBar()
  spawnDamageNum(round(amt * damage_mult))

func _on_audio_stream_player_2d_finished() -> void:
  if health <= 0 :
    emit_signal("death")

func scaleHealth() :
  var more: float = 1
  var last: float = 0.0
  
  for i in range(len(get_tree().get_nodes_in_group("player"))) :
    more += last
    last = last + (1 - last) * .35
  
  set_max_hp(int(max_health * more))

var iframes: Dictionary[String, float] = {}

func add_iframes(i_group: String, i_amt: float) :
  iframes[i_group] = i_amt
  
func has_iframes(i_group: String) :
  return i_group in iframes
