extends Control

class_name LobbyManager

@export var READY_WAIT_TIME = 5

@export var STARTER_WEAPONS: Array[Weapon]

@export var WAVE_MNGR: WaveManager

var weaponPedestalScene = preload("res://Lobby/weapon_equip.tscn")

func _ready() -> void:
  var idx: int = 0
  
  for i in STARTER_WEAPONS :
    var pedestal: WeaponPedestal = weaponPedestalScene.instantiate()
    pedestal.EQUIP_WEAPON = i
    pedestal.global_position.x = (idx - (len(STARTER_WEAPONS) - 1) / 2.0) * 500
    pedestal.global_position.y = -250
    idx += 1
    
    get_tree().get_root().add_child.call_deferred(pedestal)

var joined: Dictionary[int, bool] = {}
var deviceToPlayer: Dictionary[int, Player] = {}

var starting = false

@onready var timer: Timer = $Timer

@onready var startIn: RichTextLabel = %startIn
@onready var playerContainer: HBoxContainer = %playerContainer

var playerTexts: Dictionary[int, LobbyPLayerDisp] = {}
var playerWeapons: Dictionary[int, int] = {}

var pnames: Dictionary[int, String] = {}
var usednames: Array[String] = []

var spawnedPlayers: Dictionary[int, Player] = {}

var playerDispScene = preload("res://Lobby/lobby_player_display.tscn")

func addPlayer(id: int) :
  if id in joined :
    return
    
  var player: Player = player_scene.instantiate()
  var hud: HUDTemplate = hud_template.instantiate()
  
  player.DEVICE_ID = id
  player.HUD = hud
  player.WAVE_MNGR = WAVE_MNGR
  player.equip_weapon(STARTER_WEAPONS[0])
  player.NAME = "Player %s" % [id + 1]
  
  deviceToPlayer[id] = player
  
  player.global_position = Vector2.ZERO
  
  get_tree().get_root().add_child(player)
  %players.add_child.call_deferred(hud)
  
  player.healtcomponent.damaged.connect(func(x):
    %damage_indicator.add_extra_f(x / 25.0)
  )
  
  spawnedPlayers[id] = player
  
  joined.get_or_add(id, false)
  
  var offset = 0
  var wanted_name: String = "Player %s" % [id+1]
  if wanted_name in usednames :
    while "Player %s" % [id+1+offset] in usednames :
      offset += sign(id)
  
  
  var disp: LobbyPLayerDisp = playerDispScene.instantiate()
  disp.player_name = "Player %s" % [id+1]
  
  playerContainer.add_child(disp)
  
  playerTexts[id] = disp
  playerWeapons[id] = 0
  playersMoved[id] = false
  
  playerTexts[id].weapon_name = STARTER_WEAPONS[playerWeapons[id]].NAME
  playerTexts[id].weapon_desc = STARTER_WEAPONS[playerWeapons[id]].DESCRIPTION

func removePlayer(id: int) :
  joined.erase(id)
    
  playerTexts[id].queue_free()
  playerTexts.erase(id)
  
  playerWeapons.erase(id)
  
  playersMoved.erase(id)
  
  spawnedPlayers[id].HUD.queue_free()
  spawnedPlayers[id].queue_free()
  spawnedPlayers.erase(id)

func stopTimer() :
  starting = false
  timer.stop()

var playersMoved: Dictionary[int, bool] = {}

var has_keyboard: bool = false

func _input(event: InputEvent) -> void:
  
  if event is InputEventKey :
    var e: InputEventKey = event
    if !e.pressed :
      return
    
    if e.keycode == Key.KEY_ENTER and !-1 in joined :
      stopTimer()
      addPlayer(-1)
      $join.play()
      has_keyboard = true
    
    if !-1 in joined :
      return
      
    if e.keycode == Key.KEY_ESCAPE and -1 in joined :
      stopTimer()
      removePlayer(-1)
      has_keyboard = false
      return
      
    if joined[-1] :
      return
      
    return
  
  if not event is InputEventJoypadButton :
    return
  
  var ev: InputEventJoypadButton = event
  
  if not ev.pressed :
    return
  
  if ev.button_index == 0 and not ev.device in joined :
    stopTimer()
    addPlayer(ev.device)
    $join.play()
  
  if ev.button_index == 1 and ev.device in joined :
    stopTimer()
    removePlayer(ev.device)

var player_scene = preload("res://Player/player.tscn")
var hud_template = preload("res://HUD/hud_template.tscn")

func _process(_delta: float) -> void:
  for i in joined :
    var hue = 1.0/len(joined)*joined.keys().find(i)
    
    playerTexts[i].player_hue = hue
    spawnedPlayers[i].MAIN_COLOR = hue

func _on_timer_timeout() -> void:
  if not starting :
    return
  
  %xpManager.setLevel(len(joined))

func _on_dungeon_manager_room_changed() -> void:
  visible = false
  process_mode = Node.PROCESS_MODE_DISABLED
