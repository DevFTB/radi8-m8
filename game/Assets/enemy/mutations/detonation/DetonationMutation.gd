extends Node2D
export (int) var relativeProbability
export (PackedScene) var explosion

export (float) var detonationTime = 5
export (float) var damage = 10
export (float) var detonationRange = 800
export (AudioStream) var sound


export var engagementRadius = 30

var timer: float = 0.0;
var detonating: bool = false;

var targets = []

enum {
	LEFT,
	RIGHT
}

func equip():
	$AnimatedSprite.play("equip")
	$Area2D/CollisionShape2D.shape.radius = detonationRange
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if(detonating):
		timer += delta;
		
	if(detonating && timer > detonationTime):
		fire();

func attack():
	if(!detonating):
		timer = 0
		detonating = true
		
		$AnimatedSprite.play("detonate")
		$AudioStreamPlayer2D.play()
		
		
		#var sprite_frames = $AnimatedSprite.get_sprite_frames()
		#var amntOfFrames = sprite_frames.get_frame_count("detonate")
		
		#$AnimatedSprite.set_speed_scale(amntOfFrames / detonationTime)

func fire():
	var areas = $Area2D.get_overlapping_areas()
	
	var instance = explosion.instance()
	instance.explode(sound)
	get_tree().root.add_child(instance)
	instance.set_global_position(self.global_position)
	
	var factor = detonationRange / 128
	instance.apply_scale(Vector2(factor, factor))
	
	for area in areas:
		area.emit_signal("damage", self)	
	# blowup


func _on_Area2D_area_entered(area):
	pass # Replace with function body.


func _on_Area2D_area_exited(area):
	pass # Replace with function body.
