extends Node

signal move_player(x, y)
export (NodePath) var room_controller_path
export (NodePath) var level_path
export (NodePath) var player
var room_controller

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const n_rooms = 10
var level
var navmesh = null
var room = null

# Called when the node enters the scene tree for the first time.
func _ready():
	room_controller = get_node(room_controller_path)
	room_controller.build_room_network(n_rooms)
	level = get_node(level_path)
	for node in level.get_children():
		node.queue_free()
	level.add_child(room_controller.get_current_room())
	pass # Replace with function body.

func change_room(door_x_index, door_y_index):
	for node in level.get_children():
		node.queue_free()
	level.add_child(room_controller.change_room(door_x_index, door_y_index))
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass	


func _on_Player_door_collision(tile_index):
	change_room(tile_index[0], tile_index[1])
	get_node(player).position = Vector2(300, 100)
	
