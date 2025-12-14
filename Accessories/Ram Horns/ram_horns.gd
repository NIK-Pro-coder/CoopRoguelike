extends Accessory

var dmg_area_scene = preload("res://DamageAreas/player_damage_area.tscn")

func on_dash(player: Player):
  var area: DamageArea = dmg_area_scene.instantiate()
  var shape:= CollisionShape2D.new()
  shape.shape = RectangleShape2D.new()
  (shape.shape as RectangleShape2D).size = Vector2(64, 128)
  
  area.add_child(shape)
  area.damage = int(ceil(player.weapon.damage / 2.0))
  area.attacker = player
  area.global_position = player.global_position
  area.iframe_amount = 1
  area.iframe_group = str(player.get_instance_id())
  
  player.get_tree().get_root().add_child.call_deferred(area)
