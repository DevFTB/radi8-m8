extends TileMap

export (Array, PackedScene) var DoorColliders
const door_tile_names = ["frontdoor", "rightdoor", "backdoor", "leftdoor"]


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_door_tileid():
	return {
		0: tile_set.find_tile_by_name(door_tile_names[0]),
		1: tile_set.find_tile_by_name(door_tile_names[1]),
		2: tile_set.find_tile_by_name(door_tile_names[2]),
		3: tile_set.find_tile_by_name(door_tile_names[3])
	}

func get_scene_door_locations():
	var door_locations = [0, 0, 0, 0]
#	for door in room_scene.get_children():
#		if DoorPath.has(door.get_filename()):
#			door_locations[DoorPath[door.get_filename()]] = door.position
#	return door_locations
	var tile_ids = get_door_tileid()
	for door in tile_ids.keys():
		var door_location = get_used_cells_by_id(tile_ids[door])
		if len(door_location) != 1:
			print("multiple doors of ", door)
		if len(door_location) > 0:
			door_locations[door] = door_location[0]
	return door_locations

func replace_doors(doors):
#	# root node of room_scene is tilemap
	var door_locations = get_scene_door_locations()
	for door in range(0, len(doors)):
		if not doors[door]:
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
