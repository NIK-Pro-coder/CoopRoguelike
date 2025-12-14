extends BaseNpc
class_name BaseShopkeeper

@export var LOOT_TABLE: LootTable
@export var PEDESTALS: Array[ItemPedestal]

func _ready() -> void:
  for i in range(len(PEDESTALS)) :
    PEDESTALS[i].DISPLAY_ITEM = LOOT_TABLE.pick_random_item()
