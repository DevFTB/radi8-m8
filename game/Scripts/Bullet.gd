extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed = 10
var velocity = Vector2()
var fire_direction = Vector2()

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	position += fire_direction * speed
