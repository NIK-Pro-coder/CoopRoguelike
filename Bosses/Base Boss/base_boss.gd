extends CharacterBody2D
class_name Boss

@export var cam: MainCamera

var damageAreaScene: PackedScene = load("res://DamageAreas/enemy_damage_area.tscn")
var telegraphScene: PackedScene = preload("res://Telegraphs/generic_telegraph.tscn")

func get_square_damage_area(size: Vector2) :
  var a: DamageArea = damageAreaScene.instantiate()
  var shape := CollisionShape2D.new()
  
  shape.shape = RectangleShape2D.new()
  (shape.shape as RectangleShape2D).size = size
  
  a.add_child(shape)
  a.piercing = -1
  
  return a

func get_closest_player() :
  var p: Player = null
  var p_dist: float = -1
  
  for i in get_tree().get_nodes_in_group("player") :
    if !"ally" in i.get_groups() :
       continue
    
    if p_dist < 0 or global_position.distance_squared_to((i as Player).global_position) < p_dist :
      p_dist = global_position.distance_squared_to((i as Player).global_position)
      p = i
  
  return p

@export var NAME: String = "[BOSS NAME]"
@export var TITLE: String = "[BOSS TITLE]"

## An array of health percentages, represented as floats, where the phases stop
@export var PHASES: Array[float]

@export var PHASE_PATTERNS: Dictionary[int, Array] = {}

@export var STUN_TIME: float = 3

@onready var Icon: AnimatedSprite2D = %icon
@onready var HpComp: HealthComponent = %healthCoponent

@onready var StunTime: Timer = %stun_timer

func _ready() -> void:
  HpComp.scaleHealth()

func get_current_phase() :
  if HpComp.health <= 0 :
    return -1
  
  var phase = 0
  var hp_w = HpComp.health / float(HpComp.max_health)
  
  for i in PHASES :
    if hp_w > i :
      break
    
    phase += 1
  
  return phase

var started_fight: bool = false
var atk_pattern: Array = []
var attacking = false

var despair = false

signal defeated

func die() :
  queue_free()
  for i in get_tree().get_nodes_in_group("telegraph") :
    i.queue_free()
  
  emit_signal("defeated")

func desperation_phase() :
  if !-1 in PHASE_PATTERNS :
    die()
    return
  
  if len(atk_pattern) == 0 :
    if despair :
      die()
      return
    
    despair = true
    atk_pattern = PHASE_PATTERNS[-1].pick_random()
  
  var pattern: String = atk_pattern.pop_front()
  
  attacking = true
  self.call(pattern)

var last_phase = -1
var introducing = false

func play_introduction() :
  cam.locked = true
  cam.lock_pos = global_position
  cam.lock_zoom = .3
  
  introducing = true
  
  Icon.play("intro_roar")
  
  await get_tree().create_timer(2.5).timeout
  
  Icon.play("idle")
  
  cam.locked = false
  introducing = false

func _process(_delta: float) -> void:
  HpComp.invincible = introducing
  
  if introducing :
    return
  
  if attacking :
    return
  
  if get_current_phase() != last_phase and len(atk_pattern) == 0 :
    last_phase = get_current_phase()
    play_introduction()
    return
    
  if HpComp.health <= 0 :
    desperation_phase()
    return
  
  if StunTime.time_left > 0 :
    Icon.modulate.a = 1 - (StunTime.time_left / STUN_TIME) * .5
    (HpComp.DISPLAY_BAR.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color(0.685, 0.481, 0.0, .75)
    return
  
  (HpComp.DISPLAY_BAR.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color(1.0, 0.329, 0.369, 0.749)
  Icon.modulate.a = 1
  
  if len(atk_pattern) > 0 :
    var pattern: String = atk_pattern.pop_front()
    
    attacking = true
    self.call(pattern)
    
    return
  
  if started_fight :
    StunTime.start(STUN_TIME)
  
  started_fight = true
  
  if !get_current_phase() in PHASE_PATTERNS :
    return
    
  atk_pattern = (PHASE_PATTERNS[get_current_phase()].pick_random() as Array[String]).duplicate()
