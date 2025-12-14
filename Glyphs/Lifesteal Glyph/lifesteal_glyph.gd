extends Glyph

func _on_hit(_body: Node2D, dmg: int) :
  var heal_factor = .05 + (.05 * glyph_level)
  player.healtcomponent.healDmg(ceil(dmg * heal_factor))
