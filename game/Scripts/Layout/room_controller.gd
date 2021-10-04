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

enum {
	SHOP, 
	TIER1,
	TIER2,
	TIER3
}

var room = {}
var connections = {}
var current_room = [0, 0]
var door_to_dir = {0: [0, 1], 1: [1, 0], 2: [0, -1], 3: [-1, 0]}
var added_connections = {}
var removed_connections = {}

const door_to_new_door = {0: 2, 1: 3, 2:0, 3:1}
var exited_door = 0
export (Array, PackedScene) var room_possibilities
export (PackedScene) var shop
export var shop_chance = 0.1
export (int) var initial_edges = 150
export (int) var mutate_edge_num = 10
var possible_connections = []
var room_info = {}
var max_room = 1

const door_tile_names = ["frontdoor", "rightdoor", "backdoor", "leftdoor"]


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
	var room_packedscene = room[[x_index, y_index]].scene
	var new_room_scene = room_packedscene.instance()
#	replace_doors(new_room_scene, get_doors(x_index, y_index))
	var tile_map = new_room_scene.get_node("TileMap")
	tile_map.replace_doors(get_doors(x_index, y_index))
	
	return new_room_scene
	
func get_current_room():
	return get_room(current_room[0], current_room[1])
	
func set_room(x_index, y_index):
	current_room = [x_index, y_index]
	print("room changed to " + str(x_index) + ", " + str(y_index))
	var this_room = get_room(x_index, y_index)
	if max(x_index, y_index) > max_room:
		max_room = max(x_index, y_index)
	return this_room
	
func change_room(tile_name):
	# refactor to not instansiate another scene if possible

	var curr = room[current_room]
	curr["state"] =	get_parent().room.get_state()
	var room_scene = get_current_room()
	var door = door_tile_names.find(tile_name)
	if(door != -1):
		var dir = door_to_dir[door]
		exited_door = door_to_new_door[door]
		return set_room(current_room[0] + dir[0], current_room[1] + dir[1])
	print("no valid doors found")
	
	
#func replace_doors(room_scene, doors):
##	# root node of room_scene is tilemap
#	var tilemap = room_scene.get_node("TileMap")
#	var door_locations = tilemap.get_scene_door_locations()
#	for door in range(0, len(doors)):
#		if not doors[door]:
#			remove_door_from_tilemap(tilemap, door_locations[door], door)
			
# todo: replace door with random wall of correct type
#func remove_door_from_tilemap(tilemap, door_location, door):
#	match door:
#		0: 
#			tilemap.set_cell(door_location[0], door_location[1], 0)
#			tilemap.set_cell(door_location[0] + 1, door_location[1], 0)
#		1: 
#			tilemap.set_cell(door_location[0], door_location[1], 0)
#			tilemap.set_cell(door_location[0], door_location[1] + 1, 0)
#		2: 
#			tilemap.set_cell(door_location[0], door_location[1], 0)
#			tilemap.set_cell(door_location[0] + 1, door_location[1], 0)
#		3: 
#			tilemap.set_cell(door_location[0], door_location[1], 0)
#			tilemap.set_cell(door_location[0], door_location[1] + 1, 0)


	

#func get_scene_door_locations(room_scene):
#	var door_locations = [0, 0, 0, 0]
##	for door in room_scene.get_children():
##		if DoorPath.has(door.get_filename()):
##			door_locations[DoorPath[door.get_filename()]] = door.position
##	return door_locations
#	var tilemap = room_scene.get_node("TileMap")
#	var tile_ids = get_door_tileid(tilemap)
#	for door in tile_ids.keys():
#		var door_location = tilemap.get_used_cells_by_id(tile_ids[door])
#		if len(door_location) != 1:
#			print("multiple doors of ", door)
#		if len(door_location) > 0:
#			door_locations[door] = door_location[0]
#	return door_locations
		

#func get_door_tileid(tile_map):
#	var tile_set = tile_map.tile_set
#	return {
#		0: tile_set.find_tile_by_name(door_tile_names[0]),
#		1: tile_set.find_tile_by_name(door_tile_names[1]),
#		2: tile_set.find_tile_by_name(door_tile_names[2]),
#		3: tile_set.find_tile_by_name(door_tile_names[3])
#	}
#
func get_doors(x_index, y_index):
	var doors = [0, 0, 0, 0]
	for door in door_to_dir.keys():
		var dir = door_to_dir[door]
		var neighbour = [x_index + dir[0], y_index + dir[1]]
		if connections.has([[x_index, y_index], neighbour]):
			doors[door] = 1
	return doors
	
func rebuild_room_connections():
	removed_connections = {}
	added_connections = {}
	
	var removed = 0;
	var possible_connections_instance = possible_connections.duplicate(true)
	possible_connections_instance.shuffle()
	var spanning_tree_edges = dfs_get_spanning_tree(current_room)
	while len(possible_connections_instance) > 0 and removed < mutate_edge_num:
		var newEdge = possible_connections_instance.pop_back()
		if not spanning_tree_edges.has(newEdge) and connection_exists(newEdge[0], newEdge[1]):
			remove_connection(newEdge[0], newEdge[1])
			removed_connections[newEdge] = true
			removed_connections[[newEdge[1], newEdge[0]]] = true
			removed += 1
	
	var possible_connection_instance_add = possible_connections.duplicate(true)
	possible_connection_instance_add.shuffle()
	while removed > 0 and len(possible_connection_instance_add) > 0:
		var newEdge = possible_connection_instance_add.pop_back()
		if not connection_exists(newEdge[0], newEdge[1]):
			add_connection(newEdge[0], newEdge[1])
			added_connections[newEdge] = true
			added_connections[[newEdge[1], newEdge[0]]] = true
			removed -= 1
	
	
func build_room_network(n):
	randomize()
	var allowed_rooms = get_allowed_rooms()
	for i in range(0, n):
		for j in range(0, n):
			if (randf() < shop_chance):
				room[[i, j]] = {"scene": shop, "type": SHOP, "visited": false, "state": null}
			else:
				room[[i, j]] =  {"scene": allowed_rooms[randi() % len(allowed_rooms)], "type": TIER1, "visited": false, "state": null}
	
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
	
#func get_door_world_location(door):
#	var room_scene = get_current_room()
#	var tile_map = get_node("TileMap")
#	print(room_scene, tile_map)
#	if(room_scene):
#		return tile_map.map_to_world(tile_map.get_scene_door_locations(room_scene)[door])
		
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
	
func connection_removed(i, j):
	return removed_connections.has([i, j])

func connection_added(i, j):
	return added_connections.has([i, j])

func get_max_room():
	return max_room
## todo
#func get_current_room_instance():
