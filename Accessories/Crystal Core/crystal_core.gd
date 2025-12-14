extends Accessory

func on_hit_dealt(player: Player, atk: DamageArea, _enemy: Enemy):
  player.mana = min(player.get_actual_stat("max_mana"), player.mana + int(atk.damage * .5))
