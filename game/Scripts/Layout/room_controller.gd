extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const n_rooms = 10
const room_path = "res://Assets/Rooms"
enum Direction {TOP, RIGHT, BOTTOM, LEFT}
const DoorPath = {
	"res://Assets/Doors/Top.tscn": Direction.TOP,
	"res://Assets/Doors/Right.tscn": Direction.RIGHT,
	"res://Assets/Doors/Bottom.tscn": Direction.BOTTOM,
	"res://Assets/Doors/Left.tscn": Direction.LEFT
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func allocate_room():
	pass

#todo: ensure directory checking works in build project, pass in rooms as array in inspector?
func get_allowed_rooms():
	var room_possibilities = []
	var dir = Directory.new()
	
	if dir.open("res://Assets/Rooms") == OK:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				room_possibilities.append(dir.get_current_dir() + "/" + file)
		dir.list_dir_end();
	else:
		print("An error occurred when trying to access the path.")
	
	return room_possibilities
	
	
func get_room(x_index, y_index):
	# get correct room scene
	var cur_room_path = get_allowed_rooms()[0]
	var new_room_scene = load(cur_room_path).instance()
	replace_doors(new_room_scene, get_doors(x_index, y_index))
	
	return new_room_scene
	
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
			door_locations[DoorPath[door.get_filename()]] = door.global_position
	return door_locations
	
func get_doors(x_index, y_index):
	return [1, 0, 0, 1]
	
func rebuild_room_connections():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
