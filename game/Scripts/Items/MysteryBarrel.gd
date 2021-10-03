extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var value = -0.2
export var spawn_chance = 1
export var buff_type = "attack_interval"
var shop_items = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_pickup(player):
	shop_items.shuffle()
	var spawned = shop_items[0].instance()
	spawned.transform = transform
	get_parent().add_child(spawned)
	if ("shop_items" in spawned):
		spawned.shop_items = shop_items
	spawned.get_node("Item").remove_cost()

func destroy():
	queue_free()

