extends Resource

class_name Biome

@export var BIOME_NAME: String
@export var ROOM_POOL: Array[DungeonRoom]
@export var BIOME_TILESET: TileSet

@export_subgroup("Enemies")
@export var ENEMY_POOL: Array[PackedScene]
@export var MINIBOSS_POOL: Array[PackedScene]
@export var BOSS: PackedScene
