extends ColorRect
class_name DamageIndicator

var extra_f: float = 0

func add_extra_f(amt: float) :
  extra_f += amt

func _process(_delta: float) -> void:
  extra_f = max(0, extra_f - 0.05)
  
  var total_max_hp: float = 0
  var actual_hp: float = 0
  
  for i in get_tree().get_nodes_in_group("player") :
    total_max_hp += (i as Player).healtcomponent.max_health
    actual_hp += (i as Player).healtcomponent.health
  
  (material as ShaderMaterial).set_shader_parameter("damage_taken", (1.0 - actual_hp / total_max_hp) + extra_f / 10.0)
