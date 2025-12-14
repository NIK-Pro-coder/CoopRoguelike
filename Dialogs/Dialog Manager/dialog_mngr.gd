extends Control
class_name DialogMngr

@onready var Box: RichTextLabel = %dialog_box

@onready var NpcName: RichTextLabel = %npc_name
@onready var PlayerName: RichTextLabel = %player_name

@onready var ContinueText: RichTextLabel = %continue_text

@onready var NpcIcon: TextureRect = %npc_icon
@onready var PlayerIcon: TextureRect = %player_icon

var device_id: int = -1

var dialog: Dialog
var dialog_progress: int = 0

var text_progress: int = 0

func _ready() -> void:
  visible = false

func update_dialog() :
  var box: DialogBox = dialog.DIALOG_BOXES[dialog_progress]
  
  Box.text = box.TEXT
  
  if box.SPEAKER == DialogBox.SPEAKER_TYPES.Player :
    PlayerIcon.modulate = Color.WHITE
    NpcIcon.modulate = Color(1, 1, 1, .35)
  else :
    NpcIcon.modulate = Color.WHITE
    PlayerIcon.modulate = Color(1, 1, 1, .35)
  
  NpcName.modulate = NpcIcon.modulate
  PlayerName.modulate = PlayerIcon.modulate

func show_dialog(d: Dialog) :
  dialog = d
  visible = true
  get_tree().paused = true
  
  dialog_progress = 0
  text_progress = 0
  
  NpcName.text = d.NPC_NAME
  PlayerName.text = d.PLAYER_NAME
  
  NpcIcon.texture = d.NPC_ICON
  PlayerIcon.texture = d.PLAYER_ICON
  
  update_dialog()

func _process(_delta: float) -> void:
  if !visible :
    return
  
  text_progress += 1
  Box.visible_characters = text_progress

  ContinueText.visible = Box.visible_ratio >= 1
  if ContinueText.visible and (Input.is_action_pressed("k_revive") if device_id < 0 else Input.is_joy_button_pressed(device_id, JOY_BUTTON_Y)) :
    dialog_progress += 1
    if dialog_progress >= len(dialog.DIALOG_BOXES) :
      visible = false
      get_tree().paused = false
      return
    
    update_dialog()
  
    text_progress = 0
