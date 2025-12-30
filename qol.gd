extends Node

var RARITY_COLORS: Dictionary[Item.Rarity, Color] = {
  Item.Rarity.COMMON: Color(1.0, 1.0, 1.0),
  Item.Rarity.UNCOMMON: Color(0.0, 0.78, 0.067),
  Item.Rarity.RARE: Color(0.0, 0.467, 1.0),
  Item.Rarity.EPIC: Color(0.765, 0.0, 1.0),
  Item.Rarity.MYTHIC: Color(1.0, 0.0, 0.0),
  Item.Rarity.LEGENDARY: Color(1.0, 0.851, 0.0),
}

func create_atk(enemy: bool = false) -> AtkBuilder :
  var atk := AtkBuilder.new()
  
  return atk.create_atk(get_tree(), enemy)

func create_timer(timeout: Callable, time: float = 1) -> Timer :
  var t := Timer.new()

  get_tree().get_root().add_child.call_deferred(t)
  
  t.wait_time = time
  t.one_shot = true
  t.autostart = true
  t.timeout.connect(func():
    if t.one_shot :
      t.queue_free()
    if timeout :
      timeout.call()
  )
  
  return t

func addHitstop(time: float) :
  var t := create_timer(func() :
    get_tree().paused = false
  , time)
  t.process_mode = Node.PROCESS_MODE_ALWAYS
  
  get_tree().paused = true

var strDisplayScene = preload("res://String Display/stringdisplay.tscn")

func display_string(pos: Vector2, text: String, time: float = 1.0) -> void :
  var disp: StringDisplay = strDisplayScene.instantiate()
  disp.LIFETIME = time
  disp.STRING = text
  
  get_tree().get_root().add_child.call_deferred(disp)
  
  disp.global_position = pos

func findNodeWithCriteria(search_start: Node, criteria: Callable) -> Node :
  if criteria.call(search_start) :
    return search_start
  
  for i in search_start.get_children():
    var r = findNodeWithCriteria(i, criteria)
    
    if criteria.call(r) :
      return r
  
  return null

func findNodeWithCriteriaFromRoot(criteria: Callable) -> Node :
  return findNodeWithCriteria(get_tree().get_root(), criteria)

func findHpComp(from: Node) -> HealthComponent :
  return findNodeWithCriteria(
    from,
    func(x: Node): return x is HealthComponent
  )
  
func findEffectComp(from: Node) -> EffectComponent :
  return findNodeWithCriteria(
    from,
    func(x: Node): return x is EffectComponent
  )

var teleScene = preload("res://Telegraphs/generic_telegraph.tscn")

func create_telegraph(size: Vector2, time: float = 1) -> GenericTelegraph :
  var t: GenericTelegraph = teleScene.instantiate()
  t.TELEGRAPH_TIME = time
  t.SHAPE_SIZE = size
  
  get_tree().get_root().add_child.call_deferred(t)
  
  return t

var BIOME_LIST: Array[Biome] = [
  preload("res://Biomes/Crystal Hollow/crystal_hollow.tres")
]
var biome_idx: int = 0

func get_current_biome() -> Biome :
  return BIOME_LIST[biome_idx]
  
var lobbyMngr: LobbyManager
var waveMngr: WaveManager
var xpMngr: XpManager
var inventory: Inventory

var dialogMngr: DialogMngr

func showDialog(dialog: Dialog, player: Player) :
  dialogMngr.device_id = player.DEVICE_ID
  dialogMngr.hue_shift = player.MAIN_COLOR
  dialogMngr.show_dialog(dialog)

var dungeonMngr: DungeonMngr

var titleCard: TitleCard

func showTitleCardForCurrentBiome() :
  _process(0)
  
  titleCard._ready()
  
  var b := get_current_biome()
  titleCard.showTitleCard(biome_idx, b.BIOME_NAME)

var mainCamera: MainCamera

func addScreenshake(amt: float) :
  mainCamera.addScreenshake(amt)

func _process(_delta: float) -> void:
  if not lobbyMngr :
    lobbyMngr = findNodeWithCriteriaFromRoot(func(x: Node): return x is LobbyManager)

  if not waveMngr :
    waveMngr = findNodeWithCriteriaFromRoot(func(x: Node): return x is WaveManager)

  if not xpMngr :
    xpMngr = findNodeWithCriteriaFromRoot(func(x: Node): return x is XpManager)

  if not inventory :
    inventory = findNodeWithCriteriaFromRoot(func(x: Node): return x is Inventory)

  if not dialogMngr :
    dialogMngr = findNodeWithCriteriaFromRoot(func(x: Node): return x is DialogMngr)

  if not dungeonMngr :
    dungeonMngr = findNodeWithCriteriaFromRoot(func(x: Node): return x is DungeonMngr)

  if not titleCard :
    titleCard = findNodeWithCriteriaFromRoot(func(x: Node): return x is TitleCard)

  if not mainCamera :
    mainCamera = findNodeWithCriteriaFromRoot(func(x: Node): return x is MainCamera)

func _ready() -> void:
  process_mode = Node.PROCESS_MODE_ALWAYS
