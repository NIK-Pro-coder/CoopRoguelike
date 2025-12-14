extends Resource
class_name DialogBox

enum SPEAKER_TYPES {
  Npc = 0,
  Player = 1
}

@export var SPEAKER: SPEAKER_TYPES
@export_multiline var TEXT: String
