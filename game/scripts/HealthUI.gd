extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var player_path;
onready var player = get_node(player_path)
var hearts = 2 setget set_hearts
var max_hearts = 4 setget set_max_hearts
onready var heart_full = $HeartFull
onready var heart_empty = $HeartEmpty


# Called when the node enters the scene tree for the first time.
func _ready():

	set_hearts(player.health)
	set_max_hearts(player.max_health)

	player.connect("health_changed", self, "set_hearts")

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	heart_full.rect_size.x = 64 * hearts
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	heart_empty.rect_size.x = 64 * max_hearts

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
