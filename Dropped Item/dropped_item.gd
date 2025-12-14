extends InteractionComponent
class_name DroppedItem

@export var ITEM: Item

func _ready() -> void:
  var place = PlaceholderTexture2D.new()
  place.size = Vector2(96, 96)
  $Sprite2D.texture = ITEM.TEXTURE if ITEM.TEXTURE else place
  $Sprite2D.scale = Vector2.ONE * 4
  
  TOOLTIP = "Pick Up %s" % [ITEM.NAME]

func findInventory(from: Node) :
  for i in from.get_children() :
    if i is Inventory :
      return i
    
    var r = findInventory(i)
    
    if r is Inventory :
      return r
  
  return null

func _on_interacted(_p: Player) -> void:
  var inv: Inventory = findInventory(get_tree().get_root())
  inv.addItem(ITEM)
  queue_free()
