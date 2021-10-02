extends Node

const RoomController = preload("res://Scripts/Layout/room_controller.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var room_controller
var room = null
var navmesh = null

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	room_controller = RoomController.new()
	change_room(0, 0)
	pass # Replace with function body.

func change_room(x_index, y_index):
	var level = $Layout
	for node in level.get_children():
		node.queue_free()
	print(room_controller.get_room(x_index, y_index))
	room = room_controller.get_room(x_index, y_index)	
	level.add_child(room)
	print(level.get_children())
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
