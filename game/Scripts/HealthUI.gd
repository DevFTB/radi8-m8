extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts
var player


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().player
	player.connect("health_changed", self, "set_hearts")
	player.connect("max_health_changed", self, "set_max_hearts")
	set_max_hearts(player.max_health)

	set_hearts(player.health)

	
func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	$HeartFull.rect_size.x = hearts * 64
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	$HeartEmpty.rect_size.x = max_hearts * 64
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
