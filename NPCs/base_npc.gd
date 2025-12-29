extends InteractionComponent
class_name BaseNpc

@export var DIALOG: Dialog

func _on_interacted(p: Player) -> void:
  if !%exit_timer.is_stopped() :
    return
  
  %exit_timer.start()
  
  
  var frameIndex: int = p.sprite.get_frame()
  var animationName: String = p.sprite.animation
  var spriteFrames: SpriteFrames = p.sprite.get_sprite_frames()
  var currentTexture: Texture2D = spriteFrames.get_frame_texture(animationName, frameIndex)
  
  DIALOG.PLAYER_ICON = currentTexture
  DIALOG.PLAYER_NAME = p.NAME
  
  Qol.showDialog(DIALOG, p)
