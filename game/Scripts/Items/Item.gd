extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var bob_time = 0.5
export var bob_distance = 16
onready var initial_pos = $Sprite.position
var end_pos
export var cost = 3
export var pickup_delay = 1.5
var pickup_timer
var timeout = false
onready var initialScale = $shadow.scale


# Called when the node enters the scene tree for the first time.
func _ready():
	end_pos = initial_pos + Vector2(0, bob_distance)
	$Label.text = str(cost)
	start_tween()
	fade_in()
	delay_pickup()
	

func remove_cost():
	cost = 0
	$Label.queue_free()
	$TextureRect.queue_free()



func delay_pickup():
	$CollisionShape2D.set_deferred("disabled", true)
	pickup_timer = get_tree().create_timer(pickup_delay)
	yield(pickup_timer, "timeout")
	$CollisionShape2D.disabled = false
	timeout = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_tween():

	$Tween.start()
	$Tween2.start()
	$Tween.interpolate_property($Sprite, "position", initial_pos, end_pos, bob_time, Tween.TRANS_QUAD)
	$Tween2.interpolate_property($shadow, "scale", 0.9 * initialScale, initialScale, bob_time, Tween.TRANS_QUAD)
	yield($Tween, "tween_completed")


	
	$Tween.interpolate_property($Sprite, "position", end_pos, initial_pos, bob_time, Tween.TRANS_QUAD)
	$Tween2.interpolate_property($shadow, "scale", initialScale, 0.9 * initialScale, bob_time, Tween.TRANS_QUAD)
	yield($Tween, "tween_completed")
	start_tween()

func fade_in():
	$Tween3.start()
	$Tween3.interpolate_property($Sprite, "modulate", 
	Color(1, 1, 1, 0.3), Color(1, 1, 1, 0.8), pickup_delay/3, 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	yield($Tween2, "tween_completed")
	$Tween3.interpolate_property($Sprite, "modulate", 
	Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.3), pickup_delay/3, 
	Tween.TRANS_LINEAR, Tween.EASE_IN)

	yield($Tween2, "tween_completed")
	$Tween3.interpolate_property($Sprite, "modulate", 
	Color(1, 1, 1, 0.3), Color(1, 1, 1, 1), pickup_delay/3, 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	


func _on_Item_area_entered(area):
	if (pickup_timer || timeout):
		if (area == get_tree().root.get_children()[0].player):
			if (owner.has_method("on_pickup") && owner.has_method("destroy")):
				if (area.pickup_item(owner, cost)):
					owner.destroy()
