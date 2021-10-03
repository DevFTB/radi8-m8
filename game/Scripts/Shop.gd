extends Navigation2D

export (Array, PackedScene) var shop_items
export (Array, int) var item_spawn_chances
export (Array, NodePath) var item_location_paths


var spawned_items = []
var item_locations = []
var rarity_list
# Called when the node enters the scene tree for the first time.
func _ready():
	rarity_list = get_item_rarity_list(shop_items)
	for path in item_location_paths:
		item_locations.append(get_node(path))

func init_room(_mutation_level):
	var items = get_items(rarity_list, item_locations.size())
	var i = 0
	for location in item_locations:
		var item = items[i].instance()
		item.position = location.position
		get_parent().add_child(item)
		if ("shop_items" in item):
			item.shop_items = shop_items.duplicate()
		if (i < (items.size() - 1)):
			i += 1

func get_items(list, count):
	list.shuffle()
	return list.slice(0, min(count, list.size()))


func get_item_rarity_list(items):
	var rarity_list = []
	for i in range(0, items.size()):
		for j in range(0, item_spawn_chances[i]):
			rarity_list.append(items[i])
	return rarity_list
