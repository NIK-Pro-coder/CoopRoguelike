extends MarginContainer
class_name HUDTemplate

var player_name: String = "Player Skibidi"
var player_color: float = 0.0

var max_hp: int = 100
var health: int = 100
var last_health: float = 0

var potion_max_charge: int = 100
var potion_charge: int = 0
var last_charge: float = 0
var potion_num: int = 0

@onready var playerName: RichTextLabel = %player_name
@onready var potionProgress: TextureProgressBar = %potion_progress
@onready var potionNum: RichTextLabel = %potion_num
@onready var healthBar: TextureProgressBar = %health_bar

func _process(_delta: float) -> void:
  last_health = last_health * .9 + health * .1
  if abs(last_health - health) <= 1 :
    last_health = health
  
  last_charge = last_charge * .9 + potion_charge * .1
  if abs(last_charge - potion_charge) <= 1 :
    last_charge = potion_charge
  
  playerName.text = player_name
  
  potionProgress.max_value = potion_max_charge
  potionProgress.value = last_charge

  potionNum.text = str(potion_num)
  
  healthBar.max_value = max_hp
  healthBar.value = last_health
  if last_health < health :
    healthBar.tint_progress = Color(0.597, 1.0, 0.0, 1.0)
  elif last_health > health :
    healthBar.tint_progress = Color(1.0, 0.416, 0.0, 1.0)
  else :
    healthBar.tint_progress = Color(1, 1, 1)
