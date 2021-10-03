extends Control

export (PackedScene) var firstLevel
export (PackedScene) var instructions

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Play_pressed():
	get_tree().change_scene_to(firstLevel)


func _on_Instructions_pressed():
	get_tree().change_scene_to(instructions)
	pass # Replace with function body.

func _on_Exit_pressed():
	get_tree().quit()


# Replace with function body.


 # Replace with function body.
