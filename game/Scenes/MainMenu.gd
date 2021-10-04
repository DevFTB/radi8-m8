extends Node

export (PackedScene) var firstLevel
export (String, FILE, "*.tscn") var instructions

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
	$Main.set_visible(false)
	$Instructions.set_visible(true)
	pass # Replace with function body.

func _on_Instructions_back_pressed():
	$Main.set_visible(true)
	$Instructions.set_visible(false)
	pass # Replace with function body.

func _on_Exit_pressed():
	get_tree().quit()


# Replace with function body.


 # Replace with function body.
