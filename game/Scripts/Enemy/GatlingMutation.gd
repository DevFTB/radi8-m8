extends Node2D


export (float) var firingSpeed = 5
export (float) var burstAmount = 10;

var timer: float = 0.0;
var burstCount: int = 0;
var attacking: bool = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("equip")
	pass # Replace with function body.

func _process(delta):
	timer += delta;
	if(attacking && timer > 1 / firingSpeed):
		fire();
		timer = 0.0;

func attack():
	attacking = true;

func fire():
	if(burstCount < burstAmount):
		$AnimatedSprite.frame = 0;
		$AnimatedSprite.play("attack")
		burstCount += 1
		print(burstCount)
		print("pew")
	else:
		attacking = false; 
		burstCount = 0
