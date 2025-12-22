extends Control

class_name HUDTemplate

@export var player_color: float = 0
@export var player_name: String = "Player -1"
@export_category("Cooldowns")
@export var potion_cooldown: int = 100
@export var potion_amt: int = 6
@export var dash_cooldown: int = 100
@export_category("Spell")
@export var spell_cooldown: int = 100
@export var spell_cost: int = 10
@export var spell_hast_target: bool = true
@export_category("Health")
@export var health: int = 100
@export var max_health: int = 100
@export var healthbar_color: Color = Color(1.0, 0.333, 0.349, 0.502)
@export_category("Mana")
@export var mana: int = 100
@export var max_mana: int = 100

var can_use_potions: bool = true

@onready var player_image: TextureRect = %playerImage
@onready var player_label: RichTextLabel = %playerName

@onready var dash_progress: TextureProgressBar = %dash

@onready var potion_progress: TextureProgressBar = %potion
@onready var potion_amount: RichTextLabel = %potionAmt

@onready var spell_progress: TextureProgressBar = %spell

@onready var healthbar: ProgressBar = %healthbar
@onready var healthtext: RichTextLabel = %healthText

@onready var manabar: ProgressBar = %manabar
@onready var manatext: RichTextLabel = %manaText

@onready var ragebar: ProgressBar = %rage_bar
var rage: float = 0

@onready var matrixbar: ProgressBar = %shield_bar
var matrix: float = 0
var matrixready: bool = false

@onready var honeybar: ProgressBar = %honey_bar
var honey: float = 0

@onready var effectContainer: GridContainer = %effects
var effects: Array[Texture2D]

func update_effects() :
  for i in effectContainer.get_children() :
    i.queue_free()
  
  for i in effects :
    var tex := TextureRect.new()
    tex.texture = i
    tex.custom_minimum_size = Vector2(32, 32)
    
    effectContainer.add_child(tex)

func _ready() -> void:
  matrixbar.add_theme_stylebox_override("fill", matrixbar.get_theme_stylebox("fill").duplicate())

func _process(_delta: float) -> void:
  ragebar.visible = rage > 0
  ragebar.value = rage * 100
  
  matrixbar.visible = matrix > 0
  matrixbar.value = matrix * 100
  
  var fillstyle: StyleBoxFlat = matrixbar.get_theme_stylebox("fill")
  if matrixready :
    fillstyle.bg_color = Color(0.0, 0.68, 0.425, 0.75)
  else :
    fillstyle.bg_color = Color(0.0, 0.647, 0.71, 0.75)
  
  honeybar.visible = honey > 0
  honeybar.value = honey * 100
  
  player_image.material = player_image.material.duplicate()
  player_image.material.set_shader_parameter("hue_shift", player_color)
  
  player_label.text = player_name
  
  dash_progress.value = dash_cooldown
    
  potion_progress.value = potion_cooldown
  #potion_progress.modulate = Color(.5,.5,.5) if potion_amt <= 0 or health >= max_health else Color.WHITE
  potion_amount.text = str(potion_amt)

  spell_progress.value = spell_cooldown
  spell_progress.modulate = Color(.25,.25,.25) if !spell_hast_target or mana < spell_cost else Color.WHITE
  
  healthbar.value = health
  healthbar.max_value = max_health
  healthtext.text = "%s / %s" % [health, max_health]
  (healthbar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = healthbar_color
  (healthbar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color.a = .5
  
  manabar.value = mana
  manabar.max_value = max_mana
  manatext.text = "%s / %s" % [mana, max_mana]
