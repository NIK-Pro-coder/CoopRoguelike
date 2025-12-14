extends Control

class_name XpManager

@onready var levelProgress: ProgressBar = $MarginContainer/VBoxContainer/levelProgress
@onready var levelText: RichTextLabel = $MarginContainer/VBoxContainer/levelProgress/levelText
@onready var timer = $Timer

var level_num = 1
var xp = 0
var max_xp = 100

@export var initial_max_xp = 100
@export var fade_time = 5
@export var xp_scaling = 50

signal levelup(timer: int)

var levelups = 0

func setLevel(lvl: int = 1) -> void:
  var more: float = 1
  var last: float = 0.0
  
  for i in range(len(get_tree().get_nodes_in_group("player"))) :
    more += last
    last = last + (1 - last) * .35
    
  max_xp = int((initial_max_xp + xp_scaling * lvl) * more)

func _ready() -> void:
  setLevel()
  
func _process(_delta: float) -> void:
  if len(get_tree().get_nodes_in_group("xporb")) :
    timer.start(fade_time)
  
  visible = !timer.is_stopped()
  modulate.a = min(1, timer.time_left)
  
  levelProgress.max_value = max_xp
  levelProgress.value = xp
  
  var pluslevel = " +%s" % levelups if levelups > 0 else ""
  var progress = " (%s / %s)" % [xp, max_xp] if xp > 0 else ""
  levelText.text = "Level %s%s%s" % [level_num-levelups, pluslevel, progress]
  
  if xp >= max_xp :
    levelups += 1
    level_num += 1
    xp -= max_xp
    setLevel(level_num)
    
func rewardLevel() :
  levelups += 1

func emitLevelUpSignal() :
  if levelups == 0 :
    return
  
  emit_signal("levelup", levelups)
  $AudioStreamPlayer2D.play()
  levelups = 0
