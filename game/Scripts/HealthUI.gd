extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var player;
var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	
func set_max_hearts(value):
	max_hearts = max(value, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
