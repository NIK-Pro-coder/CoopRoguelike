extends Control
class_name MainMenu

@export var PORT: int = 6767

@export var OTHER_LAYER: CanvasLayer
@export var LOBBY: LobbyManager

func _ready() -> void:
  visible = true
  OTHER_LAYER.visible = false
  LOBBY.process_mode = Node.PROCESS_MODE_DISABLED
  get_tree().paused = true

func _on_single_player_pressed() -> void:
  LOBBY.process_mode = Node.PROCESS_MODE_ALWAYS
  
  visible = false
  OTHER_LAYER.visible = true
  
  Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
  get_tree().paused = false
