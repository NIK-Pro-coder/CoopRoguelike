extends Node
class_name EffectComponent

var stat_changes: Dictionary[Timer, StatChange] = {}
var stat_icons: Dictionary[Timer, Texture2D] = {}

signal effects_changed

func remove_effect(t: Timer) :
  stat_changes.erase(t)
  stat_icons.erase(t)
  
  effects_changed.emit()

func add_potion(potion: Potion) :
  var t := Timer.new()
  t.wait_time = potion.DURATION
  t.one_shot = true
  
  stat_icons[t] = potion.EFFECT_ICON.duplicate()
    
  add_child(t)
  t.start(potion.DURATION)
  t.timeout.connect(remove_effect.bind(t))
  
  for i in potion.EFFECTS :    
    var t_e := Timer.new()
    t_e.wait_time = potion.DURATION
    t_e.one_shot = true
    
    stat_changes[t_e] = i.duplicate()
    stat_changes[t_e].stack_level = 1
      
    add_child(t_e)
    t_e.start(potion.DURATION)
    t_e.timeout.connect(remove_effect.bind(t_e))

  effects_changed.emit()
  
func apply_effects(stats: StatTracker) :
  for i in stat_changes.values() :
    (i as StatChange).apply(stats)
