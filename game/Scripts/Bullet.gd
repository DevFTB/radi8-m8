extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed = 3
var velocity = Vector2()
var fire_direction = Vector2()
export var bullet_range = 1600
var initial_position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_position(pos):
	initial_position = pos
	global_position = pos

func _physics_process(delta):
	if (initial_position):
		if (global_position.distance_to(initial_position) >= bullet_range):
			queue_free()
	global_position += fire_direction * speed


func _on_Hitbox_area_entered(area):
	queue_free() 
