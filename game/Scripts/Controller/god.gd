extends Node

signal move_player(x, y)
export (NodePath) var room_controller_path
export (NodePath) var container_path
export (NodePath) var level_path
export (NodePath) var player
export (NodePath) var minimap_path
var room_controller

const spawn_offset_dir = {0: Vector2.DOWN, 1: Vector2.LEFT, 2: Vector2.UP, 3: Vector2.RIGHT}
export (int) var spawn_offset = 140
onready var container = get_node(container_path)
onready var minimap = get_node(minimap_path)

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
	room = room_controller.get_current_room()
	level.add_child(room)
	pass # Replace with function body.

func change_room(door_x_index, door_y_index):
	for node in level.get_children():
		node.queue_free()
	room = room_controller.change_room(door_x_index, door_y_index)
	level.add_child(room)
	room_controller.rebuild_room_connections()
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass	


func _on_Player_door_collision(tile_index):
	change_room(tile_index[0], tile_index[1])
	var door = room_controller.get_last_exited_door()
	get_node(player).position = room_controller.get_door_world_location(door) + (spawn_offset * spawn_offset_dir[door])
#	get_node(player).position = Vector2(300, 100)	
	minimap.update()

func _process(_delta): 
	if Input.is_action_pressed("view_minimap"):
		container.visible = true
	elif container.visible:
		container.visible = false
