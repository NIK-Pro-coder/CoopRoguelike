extends Item

func _consume(p: Player) :
  p.healtcomponent.healDmg(10)
