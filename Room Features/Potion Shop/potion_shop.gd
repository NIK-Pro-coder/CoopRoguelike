extends RoomFeature

var potionShopScene: PackedScene = preload("res://Shopkeepers/potion_vendor.tscn")

func place_feature(dungeon: DungeonMngr, room: DungeonRoom) -> void:
  var s: BaseShopkeeper = potionShopScene.instantiate()
  s.global_position = Vector2.ZERO
  
  dungeon.get_tree().get_root().add_child.call_deferred(s)
  
  room.add_to_storage(s)
