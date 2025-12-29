extends Control
class_name TitleCard

@onready var floorNum: RichTextLabel = %floor_num
@onready var floorName: RichTextLabel = %floor_name
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
  visible = false

func showTitleCard(floor_num: int, floor_name: String) :
  visible = true
  floorNum.text = "Floor %s" % [floor_num + 1]
  floorName.text = "- %s -" % [floor_name]
  animationPlayer.play("show_title")
  
