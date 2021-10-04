extends Node2D


export (int) var relativeProbability

export (float) var healthBonus = 200
export (float) var regenPerSecond = 1

export (AudioStream) var equipSound
export (AudioStream) var deflectSound

var timer: float = 0.0;
var boosting: bool = false

var currentHealth

var enemy = null

func equip():
	$AnimatedSprite.play("equip")
	play_sound(equipSound)
	
	currentHealth = healthBonus
	
func _process(delta):
	currentHealth += regenPerSecond * delta
	
func offset_damage(damage):
	var amntOffset = 0
	
	if(damage > currentHealth):
		amntOffset = currentHealth
	else:
		amntOffset = damage
	
	currentHealth -= damage
	
	if(amntOffset > 0):
		play_sound(deflectSound)
	return amntOffset
	
func set_player(player):
	player = player
	
func play_sound(sound):
	$AudioStreamPlayer2D.set_stream(sound)
	$AudioStreamPlayer2D.play()
