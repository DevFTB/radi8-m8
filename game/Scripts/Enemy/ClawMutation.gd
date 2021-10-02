extends Node2D


export (float) var attackSpeed = 5
export (float) var amountOfSwipes = 10;

var timer: float = 0.0;
var swipeCount: int = 0;
var attacking: bool = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play()
	pass # Replace with function body.

func _process(delta):
	timer += delta;
	if(attacking && timer > 1 / attackSpeed):
		fire();
		timer = 0.0;

func attack():
	attacking = true;

func fire():
	if(swipeCount < amountOfSwipes):
		swipeCount += 1
		print(swipeCount)
		print("swipe")
	else:
		attacking = false; 
		swipeCount = 0
