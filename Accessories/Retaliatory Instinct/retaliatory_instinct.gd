extends Accessory

var extra_dmg: int = 0

func on_hit_taken(_player: Player, dmg: int):
  extra_dmg += int(dmg * .75)

func on_atk(_player: Player, atk: DamageArea):
  atk.damage = atk.damage + extra_dmg
  extra_dmg = 0
