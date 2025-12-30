extends MarginContainer
class_name HUDTemplate

var player_name: String = "Player Skibidi"
var player_color: float = 0.0

var max_hp: int = 100
var health: int = 100
var last_health: float = 0

var max_mana: int = 100
var mana: int = 100
var last_mana: float = 0

var potion_max_charge: int = 100
var potion_charge: int = 0
var last_charge: float = 0
var potion_num: int = 0
var max_potions: int = 0

@onready var playerName: RichTextLabel = %player_name

@onready var potionProgress: TextureProgressBar = %potion_progress
@onready var potionProgressInt: TextureProgressBar = %potion_progress_int

@onready var hpFill: TextureRect = %hp_fill
@onready var hpText: RichTextLabel = %hptext
@onready var maxHpText: RichTextLabel = %maxhptext

@onready var manaBar: ProgressBar = %manabar
@onready var manaText: RichTextLabel = %manatext

func _ready() -> void:
  hpFill.material = hpFill.material.duplicate()

func _process(_delta: float) -> void:
  last_health = last_health * .9 + health * .1
  if abs(last_health - health) <= 1 :
    last_health = health
  
  last_charge = last_charge * .9 + (potion_charge + potion_num * potion_max_charge) * .1
  if abs(last_charge - (potion_charge + potion_num * potion_max_charge)) <= 1 :
    last_charge = potion_charge + potion_num * potion_max_charge
  
  last_mana = last_mana * .9 + mana * .1
  if abs(last_mana - mana) <= 1 :
    last_mana = mana
  
  playerName.text = player_name
  
  potionProgress.max_value = potion_max_charge * float(max_potions)
  potionProgress.value = last_charge
  potionProgressInt.max_value = potionProgress.max_value
  potionProgressInt.value = floor(potionProgress.value / potion_max_charge) * potion_max_charge
  
  manaBar.max_value = max_mana
  manaBar.value = last_mana
  manaText.text = "%s / %s" % [mana, max_mana]
  
  (hpFill.material as ShaderMaterial).set_shader_parameter("fill", last_health / float(max_hp))
  (hpFill.material as ShaderMaterial).set_shader_parameter("hue_shift", player_color)
  hpText.text = str(health)
  maxHpText.text = "/%s" % [max_hp]
