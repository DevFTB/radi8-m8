extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var child           

export (int) var amount  



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func spawn():
	for i in amount:
		get_tree().root.get_children()[-1].spawn(child.instance(), global_position + Vector2(randf(), randf()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_no_health():
	spawn() # Replace with function body.
