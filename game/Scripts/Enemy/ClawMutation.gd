extends Node2D


export (float) var attackSpeed = 2
export (float) var amountOfSwipes = 10;

var timer: float = 0.0;
var swipeCount: int = 0;
var attacking: bool = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("equip")
	$Hitbox/CollisionShape2D.disabled = true

	pass # Replace with function body.

func _process(delta):
	timer += delta;
	if(attacking && timer > 1 / attackSpeed):
		fire();
		timer = 0.0;

func attack():
	$AnimatedSprite.set_speed_scale(attackSpeed);
	attacking = true;
	$Hitbox/CollisionShape2D.disabled = false
	
func cease():
	$AnimatedSprite.set_speed_scale(1);
	attacking = false; 
	swipeCount = 0
	$Hitbox/CollisionShape2D.disabled = true
	
func fire():
	if(swipeCount < amountOfSwipes):
		swipeCount += 1
<<<<<<< Updated upstream

		$AnimatedSprite.frame = 0;
		$AnimatedSprite.play("attack")
		print(swipeCount)
		print("swipe")
=======
>>>>>>> Stashed changes
	else:
		cease()
