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

const door_to_new_door = {0: 2, 1: 3, 2:0, 3:1}
var exited_door = 0
export (Array, PackedScene) var room_possibilities
export (PackedScene) var shop
export (int) var initial_edges = 150
export (int) var mutate_edge_num = 10
var possible_connections = []

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
		print("room does not exist", x_index, y_index)
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
	var tilemap = room_scene.get_node("TileMap")
	for door in range(0, len(door_locations)):
		if tilemap.world_to_map(door_locations[door])[0] == door_x_index and tilemap.world_to_map(door_locations[door])[1] == door_y_index:
			var dir = door_to_dir[door]
			exited_door = door_to_new_door[door]
			return set_room(current_room[0] + dir[0], current_room[1] + dir[1])
	print("no valid doors found")
	
	
func replace_doors(room_scene, doors):
	var door_locations = get_scene_door_locations(room_scene)
	# root node of room_scene is tilemap
	var tilemap = room_scene.get_node("TileMap")
	for door in range(0, len(doors)):
		if doors[door]:
#			tilemap.set_cellv(tilemap.world_to_map(door_locations[door]), 2)
			add_door_to_tilemap(tilemap, door_locations[door], door)

# doors this code is poo soz
# duplicate doors to make version 1 with offset 0 and 1 with offset -64
func add_door_to_tilemap(tilemap, loc, door):
	var idx = tilemap.world_to_map(loc)
	match door:
		0:
			tilemap.set_cellv(idx, 2)
		1:
			tilemap.set_cellv(idx, 3, true, false, true)
		2:
			tilemap.set_cellv(idx, 3, true, true, false)
		3:
			tilemap.set_cellv(idx, 2, false, true, true)
		_:
			print(door, " is not a valid door value")
	
	

func get_scene_door_locations(room_scene):
	var door_locations = [0, 0, 0, 0]
	for door in room_scene.get_children():
		if DoorPath.has(door.get_filename()):
			door_locations[DoorPath[door.get_filename()]] = door.position
	return door_locations
	
func get_doors(x_index, y_index):
	var doors = [0, 0, 0, 0]
	for door in door_to_dir.keys():
		var dir = door_to_dir[door]
		var neighbour = [x_index + dir[0], y_index + dir[1]]
		if connections.has([[x_index, y_index], neighbour]):
			doors[door] = 1
	return doors
	
func rebuild_room_connections():
	var removed = 0;
	var possible_connections_instance = possible_connections.duplicate(true)
	possible_connections_instance.shuffle()
	var spanning_tree_edges = dfs_get_spanning_tree(current_room)
	while len(possible_connections_instance) > 0 and removed < mutate_edge_num:
		var newEdge = possible_connections_instance.pop_back()
		if not spanning_tree_edges.has(newEdge) and connection_exists(newEdge[0], newEdge[1]):
			remove_connection(newEdge[0], newEdge[1])
			removed += 1
	
	var possible_connection_instance_add = possible_connections.duplicate(true)
	possible_connection_instance_add.shuffle()
	while removed > 0 and len(possible_connection_instance_add) > 0:
		var newEdge = possible_connection_instance_add.pop_back()
		if not connection_exists(newEdge[0], newEdge[1]):
			add_connection(newEdge[0], newEdge[1])
			removed -= 1
	
	
func build_room_network(n):
	randomize()
	var allowed_rooms = get_allowed_rooms()
	for i in range(0, n):
		for j in range(0, n):
			visited[[i, j]] = 0
			room[[i, j]] = allowed_rooms[randi() % len(allowed_rooms)]
	
	for room_idx in room.keys():
		for neighbour in get_adjacent_rooms(room_idx):
			possible_connections.append([room_idx, neighbour])
			
	build_connections()
			
func build_connections():
#	for room_idx in room.keys():
#		for neighbour in get_adjacent_rooms(room_idx):
#			add_connection(room_idx, neighbour)
	var possible_connections_instance = possible_connections.duplicate(true)
	possible_connections_instance.shuffle()
	
	dfs_edge_add(current_room)
	while len(connections.keys())/2 < initial_edges and len(possible_connections_instance) > 0:
		var newEdge = possible_connections_instance.pop_back()
		if not connection_exists(newEdge[0], newEdge[1]):
			add_connection(newEdge[0], newEdge[1])
	
func get_door_world_location(door):
	var room_scene = get_current_room()
	if(room_scene):
		return get_scene_door_locations(room_scene)[door]
		
func get_last_exited_door():
	return exited_door
	
func dfs_edge_add(v, dfs_visited={}):
	dfs_visited[v] = true
	var neighbours = get_adjacent_rooms(v)
	neighbours.shuffle()
	for neighbour in neighbours:
		if not dfs_visited.has(neighbour):
			add_connection(v, neighbour)
			dfs_edge_add(neighbour, dfs_visited)
			
func dfs_get_spanning_tree(v, dfs_visited={}, edges={}):
	dfs_visited[v] = true
	var neighbours = get_neighbours(v)
	neighbours.shuffle()
	for neighbour in neighbours:
		if not dfs_visited.has(neighbour):
			edges[[v, neighbour]] = true
			edges[[neighbour, v]] = true
			dfs_get_spanning_tree(neighbour, dfs_visited, edges)
	return edges
		
	

# i, j 2-tuples of room coordinates
func add_connection(i, j):
	connections[[i, j]] = true
	connections[[j, i]] = true
		
func connection_exists(i, j):
	if connections.has([i, j]):
		return true
	return false
	
func remove_connection(i, j):
	connections.erase([i, j])
	connections.erase([j, i])

func get_neighbours(i):
	var neighbours = []
	for dir in door_to_dir.values():
		var neighbour = [i[0] + dir[0], i[1] + dir[1]]
		if connections.has([i, neighbour]):
			neighbours.append(neighbour)
	return neighbours
			
func get_adjacent_rooms(i):
	var neighbours = []
	for dir in door_to_dir.values():
		var neighbour = [i[0] + dir[0], i[1] + dir[1]]
		if room.has(neighbour):
			neighbours.append(neighbour)
	return neighbours
