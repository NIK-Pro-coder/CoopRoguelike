extends Item

func _consume(p: Player) :
  p.mana = min(p.MAX_MANA, p.mana+10)
