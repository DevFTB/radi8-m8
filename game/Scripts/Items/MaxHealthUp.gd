extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_pickup(player):
	player.buffs["max_health"] += 1
	player.set_max_health(player.max_health + 1)

func destroy():
	queue_free()

