extends Navigation2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Array, PackedScene) var enemies
export (Array, int) var quantity

export (Array, String) var spawnable_tile_names = ["floors"]
export (int) var min_spawn_distance = 500

export (NodePath) var root

const max_spawn_attempts = 10
var enemy_count = 0

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
			enemy_count += 1
			spawn(enemy, mutation_level)
			

func spawn(enemy_scene, mutation_level):
	root = get_tree().get_root().get_children()[-1]
	var player = root.player
	var loc = find_spawn_tile(player.global_position)
#	var loc = find_spawn_tile()
	if loc:
		var enemy = enemy_scene.instance()
		enemy.connect("no_health", self, "enemy_death")
		for i in range(0, mutation_level):
			enemy.mutate()
			
		var spawn_attempt = 0
		while !root.spawn(enemy, loc) and spawn_attempt < max_spawn_attempts:
			loc = find_spawn_tile(player.global_position)
			spawn_attempt += 1
		

func find_spawn_tile(player_pos):
	while len(spawnable_tiles) > 0:
		var spawn_tile = $TileMap.map_to_world(spawnable_tiles.pop_back())
		if spawn_tile.distance_to(player_pos) >= min_spawn_distance:
			return spawn_tile
		 
func enemy_death():
	enemy_count -= 1
	if (enemy_count == 0):
		$TileMap.open_doors()
	
	
	
