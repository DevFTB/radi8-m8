extends Node2D


export (int) var bob_time = 0.5
export (int) var bob_distance = 16

var end_pos

onready var initial_pos = position

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	end_pos = initial_pos + Vector2(0, bob_distance)
	start_tween()
	pass # Replace with function body.


func start_tween():

	$Tween.start()

	$Tween.interpolate_property(self, "position", initial_pos, end_pos, bob_time, Tween.TRANS_QUAD)

	yield($Tween, "tween_completed")
	
	$Tween.interpolate_property(self, "position", end_pos, initial_pos, bob_time, Tween.TRANS_QUAD)

	yield($Tween, "tween_completed")
	start_tween()
