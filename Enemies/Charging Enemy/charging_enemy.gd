extends Enemy

@export var CHARGE_SPEED: int = 1500

var charge_windup: bool = false
var charging: bool = false
var charge_dir: Vector2

var t: GenericTelegraph

func _ready():
  super._ready()
  
  healthcomponent.add_shield(healthcomponent.max_health)

func attack(atk_target: Node2D):
  var telegraph: GenericTelegraph = telegraphScene.instantiate()
  telegraph.TELEGRAPH_TIME = 1
  telegraph.SHAPE_SIZE = Vector2(500, 200)
  telegraph.rotation = global_position.angle_to_point(atk_target.global_position)
  telegraph.global_position = global_position + (atk_target.global_position - global_position).normalized() * 250
  
  get_tree().get_root().add_child.call_deferred(telegraph)
  
  charge_windup = true
  
  telegraph.telegraph_finished.connect(func() :
    charging = true
    charge_dir = Vector2.from_angle(telegraph.rotation)
    telegraph.queue_free()
    charge_windup = false
    
    %charge_timer.start()
  )
  
  t = telegraph

func _physics_process(delta):
  if charge_windup :
    if knockback != Vector2.ZERO :
      charge_windup = false
      t.queue_free()
    
    return
    
  if charging :
    velocity = charge_dir * CHARGE_SPEED
    
    if move_and_slide() :
      charging = false
      
      %charge_timer.stop()
    
    var area: DamageArea = damageAreaScene.instantiate()
    area.iframe_group = str(get_instance_id())
    area.damage = 10
    area.global_position = global_position
    area.lifetime = .1
    area.rotation = charge_dir.angle()
    
    var shape = CollisionShape2D.new()
    
    shape.shape = RectangleShape2D.new()
    (shape.shape as RectangleShape2D).size = Vector2(100, 200)
    shape.debug_color = Color(1, 0, 0, .42)
    
    area.add_child(shape)
    
    get_tree().get_root().add_child.call_deferred(area)
    
    return
  
  super._physics_process(delta)

func on_death():
  if t :
    t.queue_free()
    charge_windup = false
    charging = false
  
  super.on_death()

func _on_charge_timer_timeout() -> void:
  charging = false
