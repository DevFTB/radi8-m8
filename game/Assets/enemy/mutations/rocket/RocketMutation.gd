extends Node2D


export (float) var boostMultiplier = 5
export (float) var duration = 10;

var timer: float = 0.0;
var boosting: bool = false

var enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("equip")

	pass # Replace with function body.

func _process(delta):
	timer += delta;
	
	if(timer > duration):
		if(enemy):
			if(enemy.has_method("set_move_speed")):
				enemy.set_move_speed(1 / boostMultiplier)

func attack():
	boosting = true;
	
	if(enemy):
		if(enemy.has_method("set_move_speed")):
			enemy.set_move_speed(boostMultiplier)

func set_owner(en):
	enemy = en
	
func set_player(player):
	player = player
	