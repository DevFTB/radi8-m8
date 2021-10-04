extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal door_collision(tile_index)

export var movementSpeed : int = 300
var currMovementSpeed : int
export var shootMovementSpeed : int = 200
export var dashSpeed : int = 1200
export var heavyAttackCooldown : float = 6
export var damage : int = 10
export var dashCooldown : float = 1.8
export var invulnerabilityPeriod = 1

var rng = RandomNumberGenerator.new()


export (PackedScene) var bullet
var velocity : Vector2 = Vector2()
var facingLeft : bool = false;
export var dashDuration = 0.2;

export (Array, String) var door_tilenames = ["backdoor", "frontdoor", "leftdoor", "rightdoor"] 
var buffs = {"max_health": 0, "dodge_chance": 0, "invulnerability_period": 0, "movement_speed": 0, "attack_interval": 0}


var dashDir = Vector2()

enum {
	IDLE,
	MOVE,
	DASH,
}
var state = IDLE
var canDash = true
var isInvulnerable = false

onready var animator: AnimationNodeStateMachinePlayback = get_node("AnimationTree").get("parameters/playback")


export (AudioStream) var runSound
export (AudioStream) var dashSound
export (AudioStream) var healSound

# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
	
	
func get_input_direction():
	var velocity = Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1 
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	return velocity.normalized()
	
func process_input():
	if Input.is_action_pressed("dash"):
		if (canDash):
			perform_dash()
			
	velocity = get_input_direction()
		
func transition(newState):
	state = newState
	match state:
		IDLE:
			animator.travel("idle")
		MOVE:
			play_sound(runSound)
			animator.travel("run")
		DASH:
			animator.travel("dash")
			pass
			
func _physics_process(delta):
	process_input()
	match state:
		IDLE:
			idle_process(delta)
			
			if(velocity.length_squared() > 0):
				transition(MOVE)
		MOVE:
			currMovementSpeed = movementSpeed
			move_process(delta)
			
			if(velocity.length() == 0 and state != IDLE):
				transition(IDLE)
		DASH:
			dash_process(delta)

func idle_process(delta):
	if ($PlayerSound.playing):
		$PlayerSound.stop()
	pass

	
func toggle_facing():
		$Sprite.scale.x = $Sprite.scale.x * -1
		facingLeft = !facingLeft;
		
func face_horizontal(dir):
	if((dir.x < 0 && !facingLeft) || (dir.x > 0 && facingLeft)):
		toggle_facing()
		
func on_dash_complete():
	$"Hurtbox/CollisionShape2D".disabled = false
	transition(MOVE)	
	
func on_dash_cooldown_complete():
	canDash = true
	
func move_process(delta):
	face_horizontal(velocity)
	
	move_and_slide(velocity * (movementSpeed + buffs["movement_speed"]))
	check_collisions()

func perform_dash():
	transition(DASH)
	play_sound(dashSound)
	canDash = false
	dashDir = get_input_direction();
	var cooldownTimer = get_tree().create_timer(dashCooldown)
	cooldownTimer.connect("timeout", self, "on_dash_cooldown_complete")
	var dashTimer = get_tree().create_timer(dashDuration)
	dashTimer.connect("timeout", self, "on_dash_complete")
	
func dash_process(delta):
	move_and_slide(dashDir * dashSpeed)
	
func check_collisions():
	pass
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var name = collision.collider.name
		if collision.collider is StaticBody2D and door_tilenames.find(name) != -1:
			emit_signal("door_collision", name)
			return
#			var tile_pos = collision.collider.world_to_map(collision.position - collision.normal)
#			print(tile_pos)
#			var tile_id = collision.collider.get_cellv(tile_pos)
#			var tile_name = collision.collider.tile_set.tile_get_name(tile_id)
#			print(tile_name)
#			if door_tilenames.has(tile_name):
#				emit_signal("door_collision", tile_name)
#				return
func play_sound(audio):
	$PlayerSound.set_stream(audio)
	$PlayerSound.play()
