extends RoomFeature

var bossSpawnerScene: PackedScene = preload("res://Move Next Dungeon/move_next_dungeon.tscn")

func place_feature(dungeon: DungeonMngr, room: DungeonRoom) -> void:
  var s: InteractionComponent = bossSpawnerScene.instantiate()
  s.global_position = Vector2.ZERO
  
  dungeon.get_tree().get_root().add_child.call_deferred(s)
  
  s.interacted.connect(func(_player): 
    if !dungeon.room_cleared :
      return
    
    if len(dungeon.get_tree().get_nodes_in_group("boss")) > 0 :
      return
    
    dungeon.spawn_boss.emit()  
    
    for i in dungeon.get_tree().get_nodes_in_group("player") :
      (i as Player).global_position = (i as Player).global_position.normalized() * (dungeon.ROOM_SIZE * .75)
    
    s.queue_free()
  )
  
  room.add_to_storage(s)
