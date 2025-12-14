extends StatChange
class_name Power

@export var NAME: String
@export_multiline var DESC: String
@export var TEXTURE: Texture2D

func apply_power(stats: StatTracker) :
  apply(stats)
