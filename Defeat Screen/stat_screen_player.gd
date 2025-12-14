extends Panel

class_name StatDisplay

var isBest: bool = false
var isWorst: bool = false

@export var displyPlayer: Player

@onready var pTexture: TextureRect = %TextureRect
@onready var pName: RichTextLabel = %playerName
@onready var pStats: RichTextLabel = %playerStats
@onready var totalPoints: RichTextLabel = %totPoints

@onready var categoryDelay: Timer = %category_delay

@onready var bestPlayer: RichTextLabel = %bestPlayer

#region MULTIPLIERS
@export var damageDoneMult: float      = 1
@export var damageGotMult: float  = -1
@export var enemyKillsMult: float   = 5
@export var bossKillsMult: float    = 20
@export var timesDiedMult: float       = -10
@export var timesRevivedMult: float   = 2
@export var healingRecievedMult: float = 0
@export var potionsDrankMult: float    = 0
#endregion

func _ready() -> void:
  pTexture.material = pTexture.material.duplicate()
  pTexture.material.set_shader_parameter("hue_shift", displyPlayer.MAIN_COLOR)

  pName.text = displyPlayer.nametag.text

func getPlayerPoints() :
  return displyPlayer.damageDone * damageDoneMult + \
  displyPlayer.damageGot * damageGotMult + \
  displyPlayer.enemyKills * enemyKillsMult + \
  displyPlayer.bossKills * bossKillsMult + \
  displyPlayer.timesDied * timesDiedMult + \
  displyPlayer.timesRevived * timesRevivedMult + \
  displyPlayer.healingGot * healingRecievedMult + \
  displyPlayer.potionsDrank * potionsDrankMult

var stats: Dictionary[String, String] = {
  "Damage Done": "damageDone",
  "Damage Recieved": "damageGot",
  "Enemies Killed": "enemyKills",
  "Bosses Killed": "bossKills",
  "Times Died": "timesDied",
  "Players Revived": "timesRevived",
}
var stat_count: int = 0
var stat_value: int = 0
var stat_increase: float = 1

func getPoints() :
  var points = 0
  
  for i in range(0, stat_count) :
    points += int(displyPlayer[stats.values()[i]] * self[stats.values()[i] + "Mult"])

  if stat_count >= len(stats.keys()) :
    return points
  
  points += int(stat_value * self[stats.values()[stat_count] + "Mult"])
  
  return points

func _process(_delta) :
  pStats.text = ""

  var points = 0
  
  for i in range(0, stat_count) :
    pStats.text += stats.keys()[i] + ": " + str(displyPlayer[stats.values()[i]]) + "\n"
    points += int(displyPlayer[stats.values()[i]] * self[stats.values()[i] + "Mult"])

  if stat_count >= len(stats.keys()) :
    totalPoints.text = "Total Points: %s" % points
    return
  
  points += int(stat_value * self[stats.values()[stat_count] + "Mult"])

  totalPoints.text = "Total Points: %s" % points

  if !categoryDelay.is_stopped() :
    return
    
  pStats.text += stats.keys()[stat_count] + ": " + str(stat_value) + "\n"
  
  if !%add_delay.is_stopped() :
    return
  
  stat_value += int(stat_increase) * sign(displyPlayer[stats.values()[stat_count]])
  stat_increase += 1
  %add_delay.start()
  
  if stat_value >= displyPlayer[stats.values()[stat_count]] :
    stat_value = 0
    stat_count += 1
    stat_increase = 1
    categoryDelay.start(1)
