extends TileMap

export (Array, PackedScene) var DoorColliders
const door_tile_names = ["frontdoor", "rightdoor", "backdoor", "leftdoor"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var door_locations

# Called when the node enters the scene tree for the first time.
func _ready():
	add_colliders()

func add_colliders():
	var locations = get_scene_door_locations()
	for door in range(0, len(locations)):
		if(locations[door]):
			var collider = DoorColliders[door].instance()
			add_child(collider)
			collider.global_position = map_to_world(locations[door])
		

func get_door_tileid():
	return {
		0: tile_set.find_tile_by_name(door_tile_names[0]),
		1: tile_set.find_tile_by_name(door_tile_names[1]),
		2: tile_set.find_tile_by_name(door_tile_names[2]),
		3: tile_set.find_tile_by_name(door_tile_names[3])
	}

func get_scene_door_locations():
	if door_locations == null:
		var door_locations_out = [0, 0, 0, 0]
	#	for door in room_scene.get_children():
	#		if DoorPath.has(door.get_filename()):
	#			door_locations[DoorPath[door.get_filename()]] = door.position
	#	return door_locations
		var tile_ids = get_door_tileid()
		for door in tile_ids.keys():
			var door_location = get_used_cells_by_id(tile_ids[door])
			if len(door_location) != 1 and len(door_location) != 0:
				print("multiple doors of ", door)
			if len(door_location) > 0:
				door_locations_out[door] = door_location[0]
		door_locations = door_locations_out
		return door_locations_out
	else:
		return door_locations

func replace_doors(doors):
#	# root node of room_scene is tilemap
	door_locations = get_scene_door_locations()
	for door in range(0, len(doors)):
		if not doors[door] and door_locations[door]:
			remove_door_from_tilemap(door_locations[door], door)
			
func remove_door_from_tilemap(door_location, door):
	match door:
		0: 
			set_cell(door_location[0], door_location[1], 0)
			set_cell(door_location[0] + 1, door_location[1], 0)
		1: 
			set_cell(door_location[0], door_location[1], 0)
			set_cell(door_location[0], door_location[1] + 1, 0)
		2: 
			set_cell(door_location[0], door_location[1], 0)
			set_cell(door_location[0] + 1, door_location[1], 0)
		3: 
			set_cell(door_location[0], door_location[1], 0)
			set_cell(door_location[0], door_location[1] + 1, 0)
			
func get_door_world_location(door):
	return map_to_world(get_scene_door_locations()[door])
