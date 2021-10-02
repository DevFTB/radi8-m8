extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum Direction {TOP, RIGHT, BOTTOM, LEFT}
const DoorPath = {
	"res://Assets/Doors/Top.tscn": Direction.TOP,
	"res://Assets/Doors/Right.tscn": Direction.RIGHT,
	"res://Assets/Doors/Bottom.tscn": Direction.BOTTOM,
	"res://Assets/Doors/Left.tscn": Direction.LEFT
}
var visited = {}
var room = {}
var connections = {}
var current_room = [0, 0]
var door_to_dir = {0: [0, 1], 1: [1, 0], 2: [0, -1], 3: [-1, 0]}
export (Array, PackedScene) var room_possibilities

func allocate_room():
	pass

#todo: ensure directory checking works in build project, pass in rooms as array in inspector?
func get_allowed_rooms():
#	var room_possibilities = []
#	var dir = Directory.new()
#
#	if dir.open("res://Assets/Rooms") == OK:
#		dir.list_dir_begin()
#		while true:
#			var file = dir.get_next()
#			if file == "":
#				break
#			elif not file.begins_with("."):
#				room_possibilities.append(dir.get_current_dir() + "/" + file)
#		dir.list_dir_end();
#	else:
#		print("An error occurred when trying to access the path.")
	return room_possibilities
	
	
	
func get_room(x_index, y_index):
	if not room.has([x_index, y_index]):
		print("room does not exist")
		return
	# get correct room scene
	var room_packedscene = room[[x_index, y_index]]
	var new_room_scene = room_packedscene.instance()
	replace_doors(new_room_scene, get_doors(x_index, y_index))
	
	return new_room_scene
	
func get_current_room():
	return get_room(current_room[0], current_room[1])
	
func set_room(x_index, y_index):
	current_room = [x_index, y_index]
	print("room changed to " + str(x_index) + ", " + str(y_index))
	return get_room(x_index, y_index)
	
# refactor to increase perfomance if necessary
func change_room(door_x_index, door_y_index):
	# refactor to not instansiate another scene if possible
	var room_scene = get_current_room()
	var door_locations = get_scene_door_locations(room_scene)
	for door in range(0, len(door_locations)):
		if room_scene.world_to_map(door_locations[door])[0] == door_x_index and room_scene.world_to_map(door_locations[door])[1] == door_y_index:
			var dir = door_to_dir[door]
			return set_room(current_room[0] + dir[0], current_room[1] + dir[1])
	print("no valid doors found")
	
	
func replace_doors(room_scene, doors):
	var door_locations = get_scene_door_locations(room_scene)
	# root node of room_scene is tilemap
	for door in range(0, len(doors)):
		if doors[door]:
			room_scene.set_cellv(room_scene.world_to_map(door_locations[door]), 3)
		
	
	

func get_scene_door_locations(room_scene):
	var door_locations = [0, 0, 0, 0]
	for door in room_scene.get_children():
		if DoorPath.has(door.get_filename()):
			door_locations[DoorPath[door.get_filename()]] = door.position
	return door_locations
	
func get_doors(x_index, y_index):
	return [1, 1, 1, 1]
	
func rebuild_room_connections():
	pass
	
func build_room_network(n):
	var allowed_rooms = get_allowed_rooms()
	for i in range(0, n):
		for j in range(0, n):
			visited[[i, j]] = 0
			room[[i, j]] = allowed_rooms[randi() % len(allowed_rooms)]
		
