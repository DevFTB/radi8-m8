extends Node2D

export (PackedScene) var bullet

export (float) var firingSpeed = 5
export (float) var burstAmount = 10;

export (AudioStream) var equipSound
export (AudioStream) var fireSound

var player: Node2D = null

var timer: float = 0.0;
var burstCount: int = 0;
var attacking: bool = false;
var enemy

enum {
	LEFT,
	RIGHT
}

func equip():
	$AnimatedSprite.play("equip")
	play_sound(equipSound)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	timer += delta;
	if(attacking && timer > 1 / firingSpeed):
		fire();
		timer = 0.0;

func attack():
	enemy.engagementRadius = 460
	attacking = true;
	
func set_player(node):
	player = node

func fire():
	if(burstCount < burstAmount):
		play_sound(fireSound)
		$AnimatedSprite.frame = 0;
		$AnimatedSprite.play("attack")
		burstCount += 1
		
		if(player):
			var b = bullet.instance()
			b.position = $"Fire Point".global_position
			b.fire_direction = (player.global_position - global_position).normalized()

			enemy.get_parent().add_child(b)

			b.look_at(player.global_position)
		
	else:
		attacking = false; 
		burstCount = 0

func set_enemy(owner):
	enemy = owner
	
func play_sound(sound):
	$AudioStreamPlayer2D.set_stream(sound)
	$AudioStreamPlayer2D.play()
