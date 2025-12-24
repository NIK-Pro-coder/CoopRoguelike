extends Enemy
class_name StateMachineEnemy

@export var STATES: Array[GDScript] = []

@onready var stateDisp: RichTextLabel = %stateDisp

var current_state: EnemyState
var actual_states: Array[EnemyState]

func set_state(state: String) :
  navAgent.target_position = global_position
  
  for i in actual_states :
    if i.get_state_name().to_lower() == state.to_lower() :
      current_state = i
      return
  
  push_error("Could not find state: '%s'" % [state.to_lower()])

func _ready() -> void:
  super._ready()
  
  for i in STATES :
    var s := EnemyState.new()
    s.set_script(i)
    
    actual_states.append(s)
  
  set_state(actual_states[0].get_state_name())

func handle_logic():
  stateDisp.visible = DEBUGGING
  stateDisp.text = "State: %s" % [current_state.get_state_name().to_upper()]

  if aggro :
    current_state.process_state(self, aggro)
