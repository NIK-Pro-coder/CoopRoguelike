extends Control

func showDefeat() :
  get_tree().paused = true
  $AnimationPlayer.play("new_animation")

var playerTemplate = preload("res://Defeat Screen/stat_screen_player.tscn")
@onready var playerStats: HBoxContainer = %HBoxContainer
var displays: Array[StatDisplay] = []

func _process(_delta: float) -> void:
  if !visible :
    if len(get_tree().get_nodes_in_group("player")) == 0 :
      return
    
    for i in get_tree().get_nodes_in_group("player") :
      if "ally" in i.get_groups() :
        return
    
    for i in get_tree().get_nodes_in_group("player") :
      var temp: StatDisplay = playerTemplate.instantiate()
      temp.displyPlayer = i
    
      displays.append(temp)
      playerStats.add_child(temp)
  
    %HUD.visible = false
    visible = true
    showDefeat()
  else :
    
    %point_progress.value = 0
    
    var maxp: int = displays[0].getPlayerPoints()
    var maxs: StatDisplay = displays[0]
    var minp: int = displays[0].getPlayerPoints()
    var mins: StatDisplay = displays[0]
    
    for i in displays :
      i.isBest = false
      if maxp == null or i.getPlayerPoints() > maxp :
        maxp = i.getPlayerPoints()
        maxs = i
      if i.getPlayerPoints() < minp :
        minp = i.getPlayerPoints()
        mins = i
      
      %point_progress.value += max(0, i.getPoints())
    
    if maxs :
      maxs.isBest = true
    
    if mins :
      mins.isWorst = true

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
  for i in displays :
    i.process_mode = Node.PROCESS_MODE_ALWAYS
