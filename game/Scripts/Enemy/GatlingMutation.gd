extends Node2D

export (int) var relativeProbability

export (PackedScene) var bullet

export (float) var firingSpeed = 2
export (float) var burstAmount = 3;

export (AudioStream) var equipSound
export (AudioStream) var fireSound

export var engagementRadius = 700

var player: Node2D = null

var timer: float = 0.0;
var burstCount: int = 0;
var attacking: bool = false;
var enemy
var rng = RandomNumberGenerator.new()

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
			b.fire_direction = (player.global_position - global_position).rotated(rng.randf_range(-0.35, 0.35)).normalized()
			enemy.get_parent().add_child(b)

			b.look_at(player.global_position)
			b.set_position($"Fire Point".global_position)
		
	else:
		attacking = false; 
		burstCount = 0

func set_enemy(owner):
	enemy = owner
	
func play_sound(sound):
	$AudioStreamPlayer2D.set_stream(sound)
	$AudioStreamPlayer2D.play()
