extends ProgressBar

@onready var Bossname: RichTextLabel = %bossname

func _process(_delta: float) -> void:
  var boss: Boss = get_tree().get_first_node_in_group("boss")
  
  if !boss :
    return

  boss.HpComp.DISPLAY_BAR = self
  boss.HpComp.updateBar()
  visible = true

  Bossname.text = "%s, %s (%s / %s)" % [boss.NAME, boss.TITLE, int(round(boss.HpComp.health)), boss.HpComp.max_health]
