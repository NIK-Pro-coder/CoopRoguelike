extends InteractionComponent

var healing_given: Dictionary[Player, int] = {}
var sitting_players: Array[Player] = []

var max_healing = 30

func _on_interacted(p: Player) -> void:
  if p in sitting_players :
    return
  
  sitting_players.push_back(p)
  if !p in healing_given :
    healing_given[p] = 0

func _process(delta: float) -> void:
  super._process(delta)
  
  if $spr.animation == "burnt" :
    $RichTextLabel.visible = false
    return

func _on_update_timer_timeout() -> void:
  for i in sitting_players :
    if !is_instance_valid(i) :
      continue

    if i.velocity != Vector2.ZERO :
      sitting_players.erase(i)
    elif healing_given[i] <= max_healing and i.healtcomponent.health < i.healtcomponent.max_health :
      i.healtcomponent.healDmg(1)
      healing_given[i] += 1
      
    if len(get_tree().get_nodes_in_group("player")) > len(healing_given.keys()) :
      return
      
    var burnt: bool = true
    for k in healing_given :
      if healing_given[k] < max_healing :
        burnt = false
        break
      
    if burnt :
      $spr.play("burnt")
