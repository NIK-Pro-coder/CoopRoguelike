extends StaticBody2D

class_name Chest

@export var LOOT_TABLE: LootTable

@export var CHEST_SIZE: int = 1
@export var STRIP_LEN: int = 15

@onready var rLeft: RichTextLabel = %rewardsLeft
@onready var rGot: HBoxContainer = %rewardsGot

var stripDisplayScene = preload("res://Chest/item_strip_display.tscn")

var offsetx = 0

var rewardsLeft = 0
var rewards: Array[Item] = []

func _ready() -> void:
  dispW += itemStrip.get_theme_constant("separation")
  
  $CanvasLayer.visible = false

@onready var itemStrip: HBoxContainer = %strip

var vel: float = 0

var strip: Array[Item]

func getItemStrip() :
  strip.clear()
  
  for i in range(STRIP_LEN) :
    strip.append(LOOT_TABLE.pick_random_item(i / float(STRIP_LEN)).duplicate())
      
  strip.shuffle()
  
  # Item #6 will always be picked
  var toGive: Item = LOOT_TABLE.pick_random_item()
  var id = strip.find(toGive)
  strip.pop_at(id)
  strip.insert(6, toGive)
  print(toGive.NAME)
  
  for i in strip :
    var disp = stripDisplayScene.instantiate()
    disp.DISPLAY_ITEM = i
    
    itemStrip.add_child(disp)

  vel = 64

var dispW = 200

@onready var selector: ColorRect = %selector

func _process(_delta: float) -> void:
  if !player :
    return
  
  if len(rewards) == 0 and rewardsLeft == CHEST_SIZE * len(get_tree().get_nodes_in_group("player")) :
    startGambling()
    return
    
  if vel == 0 and (Input.is_joy_button_pressed(player.DEVICE_ID, JOY_BUTTON_A) if player.DEVICE_ID >= 0 else Input.is_action_just_pressed("k_attack")) and $waitgamble.is_stopped() :
    $CanvasLayer/claim.visible = true
    
    var center_idx = 6
    
    rewards.append(strip[center_idx].duplicate())
    
    print(strip[center_idx].NAME)
    print()
    
    var tex := TextureRect.new()
    tex.texture = strip[center_idx].TEXTURE if strip[center_idx].TEXTURE else PlaceholderTexture2D.new()
    tex.custom_minimum_size = Vector2(96, 96)
    
    rGot.add_child(tex)
    
    startGambling()
    
  $CanvasLayer/claim.visible = vel == 0
  
  rLeft.text = "%s reward%s left" % [rewardsLeft+1, "" if rewardsLeft == 0 else "s"]
  
  if !$waitgamble.is_stopped() :
    return
  
  itemStrip.position.x -= min(32, vel)
  vel = max(vel-.25, 0)
  
  if itemStrip.position.x < -(428 + offsetx + dispW) :
    itemStrip.position.x += dispW
    
    var disp = itemStrip.get_child(0)
    itemStrip.remove_child(disp)
    itemStrip.add_child(disp)

var dropItemScene = preload("res://Dropped Item/dropped_item.tscn")

func startGambling() :
  vel = 0
  
  gamble_num += 1
  
  $waitgamble.start()
  
  if rewardsLeft == 0 :
    for i in rewards :
      var dir = Vector2.from_angle(randi_range(0, 359))
      var drop: DroppedItem = dropItemScene.instantiate()
      
      drop.global_position = global_position + dir * 250
      drop.ITEM = i
      
      get_parent().add_child(drop)
      
      queue_free()
    
    $CanvasLayer.visible = false
    get_tree().paused = false
    player = null
    return
  
  rewardsLeft -= 1
  
  $CanvasLayer.visible = true
  itemStrip.position.x -= offsetx
  
  for i in itemStrip.get_children() :
    itemStrip.remove_child(i)
  itemStrip.position.x = -328
  
  getItemStrip()
  
  offsetx = randi_range(-10, 10)
  itemStrip.position.x = -428
  itemStrip.position.x += offsetx
  
  if rewardsLeft < CHEST_SIZE * len(get_tree().get_nodes_in_group("player"))-1 :
    itemStrip.position.x -= dispW * 3.25

var player: Player
var gamble_num: int = 0

func _on_interaction_interacted(p: Player) -> void:
  player = p
  
  gamble_num = 0
  
  get_tree().paused = true
  
  rewardsLeft = CHEST_SIZE * len(get_tree().get_nodes_in_group("player"))
  rewards.clear()
  for i in rGot.get_children() :
    rGot.remove_child(i)
