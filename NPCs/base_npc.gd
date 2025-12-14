extends InteractionComponent
class_name BaseNpc

@export var DIALOG: Dialog

func find_dialog_mngr(from: Node) :
  if from is DialogMngr :
    return from
  
  for i in from.get_children() :
    var r = find_dialog_mngr(i)
    
    if r is DialogMngr :
      return r
  
  return null

func _on_interacted(p: Player) -> void:
  if !%exit_timer.is_stopped() :
    return
  
  %exit_timer.start()
  
  var dialog_mngr: DialogMngr = find_dialog_mngr(get_tree().get_root())
  
  var frameIndex: int = p.sprite.get_frame()
  var animationName: String = p.sprite.animation
  var spriteFrames: SpriteFrames = p.sprite.get_sprite_frames()
  var currentTexture: Texture2D = spriteFrames.get_frame_texture(animationName, frameIndex)
  
  DIALOG.PLAYER_ICON = currentTexture
  DIALOG.PLAYER_NAME = p.NAME
  
  dialog_mngr.show_dialog(DIALOG)
  dialog_mngr.device_id = p.DEVICE_ID
