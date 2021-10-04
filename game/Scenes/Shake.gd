extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var decay =0.8
export var max_offset = Vector2(100,75)
export var max_roll = 0.1

var trauma = 0.0
var trauma_power = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	pass
	
func _process(delta):
	global_position = get_parent().global_position
	if trauma:
		trauma = max(trauma -decay * delta, 0)
		shake()
		
		
func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
