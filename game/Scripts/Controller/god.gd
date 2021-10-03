extends Node

signal move_player(x, y)
export (NodePath) var room_controller_path
export (NodePath) var level_path
export (NodePath) var player_path

var player
onready var room_controller = get_node(room_controller_path)
onready var level = get_node(level_path)


const spawn_offset_dir = {0: Vector2.DOWN, 1: Vector2.LEFT, 2: Vector2.UP, 3: Vector2.RIGHT}
export (int) var spawn_offset = 80


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const n_rooms = 10

var navmesh = null
var room = null

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	room_controller = get_node(room_controller_path)
	room_controller.build_room_network(n_rooms)

	for node in level.get_children():
		node.queue_free()
	room = room_controller.get_current_room()
	level.add_child(room)
	
	var room_data = room_controller.room[room_controller.current_room]
	room.init_room(room_data["visited"], room_data["type"], room_data["state"])
	room_data["visited"] = true
	pass # Replace with function body.

func change_room(tile_name):
	for node in level.get_children():
		node.queue_free()
	room = room_controller.change_room(tile_name)
	level.add_child(room)
	
	var room_data = room_controller.room[room_controller.current_room]
	room.init_room(room_data["visited"], room_data["type"], room_data["state"])
	room_data["visited"] = true
	room_controller.rebuild_room_connections()
	
	var door = room_controller.get_last_exited_door()
	var door_offset = 0
	match door:
		0: door_offset = 256
		3: door_offset = 128
	player.global_position = room.get_node("TileMap").get_door_world_location(door) + ((spawn_offset + door_offset) * spawn_offset_dir[door])
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass	


func _on_Player_door_collision(tile_name):
	change_room(tile_name)
#	get_node(player).position = Vector2(300, 100)	
