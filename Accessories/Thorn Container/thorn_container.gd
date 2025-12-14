extends Accessory

var dmgAreaScene = preload("res://DamageAreas/player_damage_area.tscn")

func on_heal(player: Player):
  var area: DamageArea = dmgAreaScene.instantiate()
  var shape := CollisionShape2D.new()
  shape.shape = RectangleShape2D.new()
  (shape.shape as RectangleShape2D).size = Vector2(500, 500)
  
  area.add_child(shape)
  area.damage = int(player.get_actual_stat("potion_healing") / 2)
  area.global_position = player.global_position
  area.attacker = player
  
  player.get_tree().get_root().add_child.call_deferred(area)
