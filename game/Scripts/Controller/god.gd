extends Node

const RoomController = preload("res://Scripts/Layout/room_controller.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var room_controller

# Called when the node enters the scene tree for the first time.
func _ready():
	room_controller = RoomController.new()
	pass # Replace with function body.

func change_room(x_index, y_index):
	var root = get_tree().get_root()
	var level = root.get_node("Layout")
	for node in level.get_children():
		node.queue_free()
	level.add_child(room_controller.get_room(x_index, y_index))
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
