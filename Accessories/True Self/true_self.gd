extends Accessory

var damageAreaScene = preload("res://DamageAreas/player_damage_area.tscn")
var damage_taken: int = 0

func on_hit_taken(player: Player, dmg: int):
  damage_taken += dmg
  
  if damage_taken >= 30 :
    damage_taken = 0
    
    var area: DamageArea = damageAreaScene.instantiate()
    area.iframe_group = str(get_instance_id())
    area.damage = 20
    area.global_position = player.global_position
    area.lifetime = .1
    
    var shape = CollisionShape2D.new()
    
    shape.shape = RectangleShape2D.new()
    (shape.shape as RectangleShape2D).size = Vector2(750, 750)
    shape.debug_color = Color(0, 1, 0, .42)
    
    area.add_child(shape)
    player.get_tree().get_root().add_child.call_deferred(area)
