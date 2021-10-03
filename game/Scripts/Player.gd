extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal health_changed
signal no_health
signal door_collision(tile_index)

export var attackInterval = 0.1

export var movementSpeed : int = 500
export var dashSpeed : int = 1500
export var heavyAttackCooldown : float = 1.2
export var damage : int = 10
export var dashCooldown : float = 2
export var invulnerabilityPeriod = 1


export (PackedScene) var bullet
var velocity : Vector2 = Vector2()
var facingLeft : bool = false;
export var dashDuration = 0.2;


var dashDir = Vector2()

enum {
	IDLE,
	MOVE,
	DASH,
	ATTACK,
	HEAVY_ATTACK
}
var state = IDLE
var canAttack = true
var canDash = true
var canHeavyAttack = true


export(int) var max_health = 10
var health = null setget set_health

onready var animator: AnimationNodeStateMachinePlayback = get_node("AnimationTree").get("parameters/playback")

func _enter_tree():
	health = max_health

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
	if Input.is_action_pressed("attack"):
		if (canAttack):
			perform_attack()
	if Input.is_action_just_pressed("heavy_attack"):
		if (canHeavyAttack && canAttack):
			perform_heavy_attack()
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
			animator.travel("run")
		ATTACK:
			if(velocity.length() == 0):
				animator.stop()
				animator.travel("fire")
			else:
				animator.stop()
				animator.travel("run")
		HEAVY_ATTACK:
			animator.travel("fire")
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
			move_process(delta)
			
			if(velocity.length() == 0 and state != IDLE):
				transition(IDLE)
		ATTACK:
			move_process(delta)
			attack_process(delta)
			
			if(velocity.length() == 0 and state != IDLE and canAttack):
				transition(IDLE)
				
		HEAVY_ATTACK:
			attack_process(delta)
			if(velocity.length() == 0 and state != IDLE and canHeavyAttack):
				transition(IDLE)
		DASH:
			dash_process(delta)

func idle_process(delta):
	pass

func attack_process(delta):
	if(velocity.length_squared()> 0):
		animator.travel("run")
	pass

func perform_attack():
	#subject to change
	transition(ATTACK)
	
	if(velocity.length() == 0):
		 animator.travel("fire")
		
	canAttack = false
	var b = bullet.instance()
	b.fire_direction = (get_global_mouse_position() - global_position).normalized()
	owner.add_child(b)

	b.position = position
	b.rotation = (get_global_mouse_position() - position).normalized().angle()
	var cooldownTimer = get_tree().create_timer(attackInterval)
	cooldownTimer.connect("timeout", self, "on_attack_cooldown_complete")
	
	if((b.fire_direction.x < 0 && !facingLeft) || (b.fire_direction.x > 0 && facingLeft)):
		toggle_facing()
	
func toggle_facing():
		$Sprite.set_flip_h(!facingLeft)
		facingLeft = !facingLeft;
		
func perform_heavy_attack():
	transition(HEAVY_ATTACK)
	
	canHeavyAttack = false
	var rng = RandomNumberGenerator.new()
	for x in range(5):
		var b = bullet.instance()
		b.fire_direction = (get_global_mouse_position() - global_position).rotated(rng.randf_range(-0.1, 0.1)).normalized()
		
		owner.add_child(b)

		b.transform = transform
		yield(get_tree().create_timer(0.05), "timeout")
	
	var cooldownTimer = get_tree().create_timer(heavyAttackCooldown)
	cooldownTimer.connect("timeout", self, "on_heavy_attack_cooldown_complete")

func on_attack_cooldown_complete():
	canAttack = true
	
func on_heavy_attack_cooldown_complete():
	canHeavyAttack = true
	
func on_dash_cooldown_complete():
	canDash = true
	
func on_dash_complete():
	transition(MOVE)	
	
func move_process(delta):
	if(state != ATTACK):
		if((velocity.x < 0 && !facingLeft) || (velocity.x > 0 && facingLeft)):
			toggle_facing()
		
	move_and_slide(velocity * movementSpeed)
	check_collisions()
	
func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", value)
	if (health == 0):
		emit_signal("no_health")

func perform_dash():
	transition(DASH)
	canDash = false
	dashDir = get_input_direction();
	var cooldownTimer = get_tree().create_timer(dashCooldown)
	cooldownTimer.connect("timeout", self, "on_dash_cooldown_complete")
	
func dash_process(delta):
	move_and_slide(dashDir * dashSpeed)
	var dashTimer = get_tree().create_timer(dashDuration)
	dashTimer.connect("timeout", self, "on_dash_complete")
	
func check_collisions():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is TileMap:
			var tile_pos = collision.collider.world_to_map(collision.position - collision.normal)
			var tile_id = collision.collider.get_cellv(tile_pos)
			if tile_id == 2 || tile_id == 3:
				emit_signal("door_collision", tile_pos)
				return
				
func take_damage(value):
	set_health(health - value)
	$"Hurtbox/CollisionShape2D".set_deferred("disabled", true)
	var timer = get_tree().create_timer(invulnerabilityPeriod)
	timer.connect("timeout", self, "on_invulnerability_end")

func on_invulnerability_end():
	$"Hurtbox/CollisionShape2D".disabled = false

func _on_Hurtbox_damage(source):
	print("somebody touch player hut box ")
	if("damage" in source):
		take_damage(source.damage)
