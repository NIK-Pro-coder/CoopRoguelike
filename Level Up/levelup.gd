extends Control

var selected = 0

@export var powers: Array[Power]

@onready var lobbymngr: LobbyManager = %lobby

@onready var confetti: GPUParticles2D = %confetti

var players

var moved = true
var askConfirm = false

var pressed = false

var selectedPowers: Array[Power] = []

func _process(_delta: float) -> void:
  var view_size := get_viewport_rect()
  
  confetti.position = Vector2(view_size.size.x/2, view_size.size.y+50)
  (confetti.process_material as ParticleProcessMaterial).emission_box_extents.x = confetti.position.x
  confetti.emitting = visible
  
  players = lobbymngr.joined.keys()
  
  if len(selectedPowers) < 1 :
    return
  
  var upgrades = $MarginContainer/VBoxContainer/powers.get_children()
  
  for i in range(len(upgrades)) :
    (((upgrades[i] as Control).get_child(0) as Panel).get_theme_stylebox("panel") as StyleBoxFlat).bg_color.a = 1.0 if i == selected else .5

  if player_turn >= len(players) :
    return

  var p_device = players[player_turn]
  
  $MarginContainer/VBoxContainer/VBoxContainer/playerName.text = "Player %s: %s upgrade%s left" % [p_device+1, max_levelups-levelup_num, "" if max_levelups-levelup_num==1 else "s"]
  $MarginContainer/VBoxContainer/confirmText.visible = askConfirm
  
  if askConfirm :
    if Input.is_joy_button_pressed(p_device, JOY_BUTTON_B) if p_device >= 0 else Input.is_action_just_pressed("k_roll") :
      askConfirm = false
    if Input.is_joy_button_pressed(p_device, JOY_BUTTON_A) if p_device >= 0 else Input.is_action_just_pressed("k_attack") :
      if !pressed :
        var player: Player = lobbymngr.deviceToPlayer[p_device]
        var power: Power = selectedPowers[selected].duplicate()
        
        var id = -1
        for i in player.powers :
          if i.NAME == power.NAME :
            id = player.powers.find(i)
        
        if id == -1 :
          player.powers.append(power)
          id = len(player.powers)-1
          
        player.powers[id].stack_level += 1
        player.recalculate_powers()
        
        loadPowers()
    else :
      pressed = false
    return
  
  if Input.is_joy_button_pressed(p_device, JOY_BUTTON_A) if p_device >= 0 else Input.is_action_just_pressed("k_attack") :
    if !pressed :
      askConfirm = true
      pressed = true
  else :
    pressed = false
  
  if !moved and (Input.get_joy_axis(p_device, JOY_AXIS_LEFT_X) < -.5 if p_device >= 0 else Input.is_action_just_pressed("k_left")) :
    selected -= 1
    moved = true
  elif !moved and (Input.get_joy_axis(p_device, JOY_AXIS_LEFT_X) > .5 if p_device >= 0 else Input.is_action_just_pressed("k_right")) :
    selected += 1
    moved = true
  elif (abs(Input.get_joy_axis(p_device, JOY_AXIS_LEFT_X)) if p_device >= 0 else Input.get_axis("k_left", "k_right")) < .5 :
    moved = false
  
  selected = selected % 5
  if selected < 0 : selected = 4

var player_turn = 0
var levelup_num = 0

func getPowers(amt: int = 5) :
  var gotten: Array[Power] = []
  var excluded: Array[Power] = []
  var player: Player = lobbymngr.deviceToPlayer[players[player_turn]]

  while len(gotten) < amt :
    var possible = powers.filter(func (a: Power): return !a in excluded and (!a in player.powers or a.stack_level < a.MAX_STACKS or a.MAX_STACKS < 0))
    
    if len(possible) == 0 :
      excluded.clear()
      possible = powers.duplicate()
    
    possible.shuffle()
    
    excluded.append(possible[0])
    gotten.append(possible[0])
  
  return gotten

var powerTemplate = preload("res://Powers/Power Template/power_template.tscn")

func loadPowers() :
  askConfirm = false
  pressed = true
  selected = 2
  
  levelup_num += 1
  if levelup_num >= max_levelups :
    levelup_num = 0
    player_turn += 1
  
  if player_turn >= len(players) :
    visible = false
    get_tree().paused = false
    
    return
  
  selectedPowers.clear()
  
  var got = getPowers()
  
  for i in $MarginContainer/VBoxContainer/powers.get_children() :
    $MarginContainer/VBoxContainer/powers.remove_child(i)
  
  var player: Player = lobbymngr.deviceToPlayer[players[player_turn]]
  
  for i in got :
    var temp: PowerTemplate = powerTemplate.instantiate()
    temp.power = i
    temp.stacks = 0
    temp.hue_shift = player.MAIN_COLOR
    
    for p in player.powers :
      if p.NAME == i.NAME :
        temp.stacks = p.stack_level
    
    $MarginContainer/VBoxContainer/powers.add_child(temp)

    selectedPowers.append(i)

var max_levelups = 0

func showLevelup(times: int) :
  get_tree().paused = true
  visible = true
  
  player_turn = 0
  levelup_num = -1
  max_levelups = times

  loadPowers()
