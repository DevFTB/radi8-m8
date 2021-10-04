extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (NodePath) var player_path;
var player

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	player = get_node(player_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
