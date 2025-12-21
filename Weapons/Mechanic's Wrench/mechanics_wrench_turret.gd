extends Area2D
class_name MechanicTurret

@onready var scrap_charge: ProgressBar = %scrap_charge
@onready var lvl_num: RichTextLabel = %lvl_num

@onready var shoot_timer: Timer = $shoot_timer

@onready var range_indicator: Sprite2D = %range_indicator

var scraps: int = 0
var level: int = 1

var player: Player

func _ready() -> void:
  range_indicator.material = range_indicator.material.duplicate()

func _process(_delta: float) -> void:
  if len(get_tree().get_nodes_in_group("enemy")) == 0 :
    shoot_timer.wait_time = 1
    (%collision.shape as CircleShape2D).radius = 450
    
    level = 1
    scraps = 0
    
    lvl_num.text = "0"
  
  if len(get_overlapping_bodies()) == 0 :
    (range_indicator.material as ShaderMaterial).set_shader_parameter("has_target", false)
  else :
    (range_indicator.material as ShaderMaterial).set_shader_parameter("has_target", true)
  
  (range_indicator.material as ShaderMaterial).set_shader_parameter("level", level)

  
  if scraps >= 50 and level < 21 :
    Qol.display_string(global_position, "Turret upgraded")
    scraps -= 50
    shoot_timer.wait_time = max(.1, 1 - level * .05)
    (%collision.shape as CircleShape2D).radius = 450 + 25 * level
    lvl_num.text = str(level) if level < 20 else "Max"
    level += 1
    if level >= 21 :
      scraps = 50
    
  range_indicator.scale = Vector2.ONE * (7.125 / 450 * (%collision.shape as CircleShape2D).radius)
  
  scrap_charge.value = scraps

func _on_timer_timeout() -> void:
  if player.healtcomponent.health <= 0 :
    return
  
  var enemies = get_overlapping_bodies()
  enemies.sort_custom(func(a: Node2D, b: Node2D): return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))

  if len(enemies) == 0 :
    return
  
  var target = enemies[0]
  
  var hp: HealthComponent = Qol.findHpComp(target)
  
  if not hp :
    return
  
  hp.dealDmg(5)
  
  var l := Line2D.new()
  l.points = [global_position, target.global_position]
  l.default_color = Color(0.71, 0.568, 0.0, 1.0)
  
  Qol.create_timer(l.queue_free, .1)
  
  get_tree().get_root().add_child.call_deferred(l)
