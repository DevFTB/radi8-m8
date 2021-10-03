extends Navigation2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Array, PackedScene) var enemies
export (Array, int) var quantity

export (Array, String) var spawnable_tile_names = ["floors"]
export (int) var min_spawn_distance = 50

export (NodePath) var root

var spawnable_tiles = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_room(visited, tier, prev_state):
	randomize()
	for name in spawnable_tile_names:
		spawnable_tiles += $TileMap.get_used_cells_by_id($TileMap.tile_set.find_tile_by_name(name))
	spawnable_tiles.shuffle()
	
	spawn_enemies(tier)


func get_state():
	return null
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn_enemies(mutation_level):
	for i in range(0, len(enemies)):
		var enemy = enemies[i]
		for j in range(0, mutation_level * quantity[i]):
			spawn(enemy, mutation_level)

func spawn(enemy_scene, mutation_level):
	var root = get_tree().get_root().get_node("Node2D2")
	var loc = find_spawn_tile()
	if loc:
		var enemy = enemy_scene.instance()
		for i in range(0, mutation_level):
			enemy.mutate()
		root.spawn(enemy, loc)
		

# non collision tiles and far enough away from player
func find_spawn_tile():
	while len(spawnable_tiles) > 0:
		var spawn_tile = $TileMap.map_to_world(spawnable_tiles.pop_back())
#		if spawn_tile.distance_to()
		return spawn_tile
		 
	
	
