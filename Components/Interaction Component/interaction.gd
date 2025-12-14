extends Area2D

class_name InteractionComponent

signal interacted(p: Player)

@export var TOOLTIP: String

@export var DISPLAY_TOOLTIP: RichTextLabel

func _process(_delta: float) -> void:
  var players = get_overlapping_bodies()

  if DISPLAY_TOOLTIP :
    DISPLAY_TOOLTIP.visible = len(players) > 0

  if len(players) > 0 and DISPLAY_TOOLTIP :
    DISPLAY_TOOLTIP.text = "(%s) %s" % [("Y" if players[0].DEVICE_ID >= 0 else "E"), TOOLTIP]

  for i in players :
    if (Input.is_joy_button_pressed(i.DEVICE_ID, JOY_BUTTON_Y) if i.DEVICE_ID >= 0 else Input.is_action_just_pressed("k_revive")) :
      emit_signal("interacted", i)
