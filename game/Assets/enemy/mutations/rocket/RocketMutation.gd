extends Node2D

export (int) var relativeProbability

export (float) var boostMultiplier = 1.5
export (float) var duration = 10;

export (AudioStream) var equipSound
export (AudioStream) var boostSound
export (AudioStream) var boostSoundTail

var timer: float = 0.0;
var boosting: bool = false

export var engagementRadius = 50

var enemy = null

func equip():
	$AnimatedSprite.play("equip")
	play_sound(equipSound)


func _process(delta):
	if(boosting):
		timer += delta;
		if(timer > duration):
			if(enemy):
				if(enemy.has_method("set_move_speed")):
					enemy.set_move_speed(1 / boostMultiplier)
					play_sound(boostSoundTail)
				boosting = false
		else:
			play_sound(boostSound)
	

func attack():
	boosting = true;
	
	if(enemy):
		if(enemy.has_method("set_move_speed")):
			enemy.set_move_speed(boostMultiplier)

func set_enemy(en):
	enemy = en
	
func set_player(player):
	player = player
	
func play_sound(sound):
	$AudioStreamPlayer2D.set_stream(sound)
	$AudioStreamPlayer2D.play()
	
