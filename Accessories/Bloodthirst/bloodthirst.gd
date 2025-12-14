extends Accessory

func on_kill(player: Player, _enemy: Enemy):
  player.effectcomponent.add_potion(load("res://Accessories/Bloodthirst/bloodthirst_potion.tres"))
