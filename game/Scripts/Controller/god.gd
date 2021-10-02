extends Node

signal move_player(x, y)

const RoomController = preload("res://Scripts/Layout/room_controller.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var room_controller
const n_rooms = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	room_controller = RoomController.new(10)
	var level = get_node("/root/Node2D/Layout")
	for node in level.get_children():
		node.queue_free()
	level.add_child(room_controller.get_current_room())
	pass # Replace with function body.

func change_room(door_x_index, door_y_index):
	var level = get_node("/root/Node2D/Layout")
	for node in level.get_children():
		node.queue_free()
	level.add_child(room_controller.change_room(door_x_index, door_y_index))
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_KinematicBody2D_door_collision(tile_index):
	change_room(tile_index[0], tile_index[1])
	emit_signal("move_player", 0, 0)
	
