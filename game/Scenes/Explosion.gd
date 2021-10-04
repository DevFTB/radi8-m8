extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func explode(sound):
	$AnimatedSprite.play('explode')
	$AudioStreamPlayer2D.set_stream(sound)
	$AudioStreamPlayer2D.play()
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimatedSprite_animation_finished():
	queue_free()
