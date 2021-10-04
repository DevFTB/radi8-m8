extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_pickup(player):
	Global.add_radpods(1)
	player.play_sound(player.moneySound)


func destroy():
	queue_free()
