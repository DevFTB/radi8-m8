extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal damage(source)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_hit(source):
	emit_signal("damage", source)
