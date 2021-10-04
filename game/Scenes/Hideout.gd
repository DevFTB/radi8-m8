extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var raid


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_raid():
	get_tree().change_scene_to(raid)


func _on_Area2D_body_entered(body):
	if body.name == "HideoutPlayer":
		load_raid()
