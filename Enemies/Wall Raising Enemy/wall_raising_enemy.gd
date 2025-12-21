extends Enemy

var telegraphs: Array[GenericTelegraph]

func attack(atk_target: Node2D):
  var angle = randi_range(-180, 180)
  
  for i in range(-45, 45, 5) :
    var telegraph: GenericTelegraph = telegraphScene.instantiate()
    telegraph.TELEGRAPH_TIME = 1
    telegraph.SHAPE_SIZE = Vector2(75, 75)
    telegraph.global_position = atk_target.global_position + Vector2.from_angle(deg_to_rad(angle + i)) * 400
    
    get_tree().get_root().add_child.call_deferred(telegraph)
    
    telegraphs.push_back(telegraph)
    
    telegraph.telegraph_finished.connect(func() :
      var area: DamageArea = Qol.create_atk(
          true
        ).set_rect_shape(
          telegraph.SHAPE_SIZE
        ).add_sprite(
          load("res://Bosses/Crystal Golem/Sprites/sliding_rock.png"),
          2
        ).instantiate()
        
      area.iframe_group = str(get_instance_id())
      area.damage = int((20 * stat_tracker.DAMAGE_PERCENT + stat_tracker.DAMAGE) * wave_scaling)
      area.global_position = telegraph.global_position
      area.lifetime = .5
      
      telegraph.queue_free()
    )

func on_death():
  super.on_death()
  
  for i in telegraphs :
    if !is_instance_valid(i) :
      continue
    
    i.queue_free()
