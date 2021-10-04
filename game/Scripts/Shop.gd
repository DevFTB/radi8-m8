extends Navigation2D

export (Array, PackedScene) var shop_items
export (Array, int) var item_spawn_chances
export (Array, NodePath) var item_location_paths


var spawned_items = []
var spawned_indices = []
var item_locations = []
var rarity_list
# Called when the node enters the scene tree for the first time.
func _ready():
	rarity_list = get_item_rarity_list(shop_items)
	for path in item_location_paths:
		item_locations.append(get_node(path))

func init_room(visited, __, prev_state):
	if (visited): 
		load_room(prev_state)
	else:
		var items = get_items(rarity_list, item_locations.size())
		spawn_items(items)

func spawn_items(indices):
	var i = 0
	for location in item_locations:
		if (indices && indices[i] != -1):
			var index = indices[i]
			var item = shop_items[index].instance()
			item.position = location.position
			get_parent().add_child(item)
			if ("shop_items" in item):
				item.shop_items = shop_items.duplicate()
			spawned_items.append(item)
			spawned_indices.append(index)
		else:
			spawned_indices.append(i)
			spawned_items.append(-1)
		if (i < (indices.size() - 1)):
			i += 1

func load_room(prev_state):
	spawn_items(prev_state)

func get_items(list, count):
	list.shuffle()
	return list.slice(0, min(count, list.size()))


func get_item_rarity_list(items):
	var rarity_list = []
	for i in range(0, items.size()):
		for j in range(0, item_spawn_chances[i]):
			rarity_list.append(i)
	return rarity_list
	
func get_state():
	for i in range(0, spawned_indices.size()):
		if !is_instance_valid(spawned_items[i]):
			spawned_indices[i] = -1
	return spawned_indices
