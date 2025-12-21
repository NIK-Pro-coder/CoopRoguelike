extends Area2D

func _on_timer_timeout() -> void:
  var pot := Potion.new()
  pot.DURATION = .49
  pot.EFFECT_ICON = load("res://Potions/Sprites/Buff Icons/speed_potion.png")
  
  var change := StatChange.new()
  change.AFFECTED_STAT = StatTracker.Stats.SPEED_PERCENT
  change.CHANGE += 20
  
  pot.EFFECTS = [change]
  
  for i in get_overlapping_bodies() :
    var effect: EffectComponent = Qol.findEffectComp(i)
    
    if effect :
      effect.add_potion(pot)
