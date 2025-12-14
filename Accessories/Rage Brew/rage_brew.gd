extends Accessory

var rage: float = 0
var depleting: bool = false

var rageEffectScene = preload("res://Accessories/Rage Brew/rage_effect.tscn")

func on_hit_taken(_player: Player, _dmg: int):
  if depleting :
    return
  rage = 0

func update_passive(player: Player):
  var has_enemeis: bool = len(player.get_tree().get_nodes_in_group("enemy")) > 0
  
  if has_enemeis and !depleting :
    rage += 0.01
  else :
    rage -= 0.02
    
  player.HUD.rage = rage
  
  rage = clamp(rage, 0, 1)
  
  if rage <= 0 :
    depleting = false
  
  if rage >= 1 :
    player.effectcomponent.add_potion(load("res://Accessories/Rage Brew/rage_potion.tres"))
    var rageEffect: GPUParticles2D = rageEffectScene.instantiate()
    rageEffect.emitting = true
    rageEffect.global_position = player.global_position
    player.get_tree().get_root().add_child.call_deferred(rageEffect)
    depleting = true
