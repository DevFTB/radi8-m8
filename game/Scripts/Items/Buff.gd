extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var value = -0.2
export var spawn_chance = 1
export var buff_type = "attack_interval"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_pickup(player):
	player.buffs[buff_type] = value

func destroy():
	queue_free()

func can_pickup(player):
	return player.buffs[buff_type] == 0

