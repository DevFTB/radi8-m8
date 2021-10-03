extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal health_changed(health)
signal max_health_changed(max_health)
signal no_health
signal door_collision(tile_index)
signal money_changed(money)

export var attackInterval = 0.5

export var movementSpeed : int = 300
export var dashSpeed : int = 1500
export var heavyAttackCooldown : float = 1.2
export var damage : int = 10
export var dashCooldown : float = 2
export var invulnerabilityPeriod = 1
export var money = 42069

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
			
			if(state != IDLE and canAttack and canHeavyAttack):
				transition(IDLE)
				
		HEAVY_ATTACK:
#			attack_process(delta)
			if(state != IDLE and canHeavyAttack):
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

	b.global_position = $Sprite/FirePosition.global_position
	b.rotation = (get_global_mouse_position() - position).normalized().angle()
	var cooldownTimer = get_tree().create_timer(attackInterval + buffs["attack_interval"])
	cooldownTimer.connect("timeout", self, "on_attack_cooldown_complete")
	
	face_horizontal(b.fire_direction)
	
func toggle_facing():
		$Sprite.scale.x = $Sprite.scale.x * -1
		facingLeft = !facingLeft;
		
func face_horizontal(dir):
	if((dir.x < 0 && !facingLeft) || (dir.x > 0 && facingLeft)):
		toggle_facing()
		
func perform_heavy_attack():
	transition(HEAVY_ATTACK)
	
	canHeavyAttack = false

	for x in range(5):
		var b = bullet.instance()
		b.fire_direction = (get_global_mouse_position() - global_position).rotated(rng.randf_range(-0.1, 0.1)).normalized()
		
		owner.add_child(b)

		b.global_position = $Sprite/FirePosition.global_position
		b.rotation = (get_global_mouse_position() - position).normalized().angle()
		yield(get_tree().create_timer(0.05), "timeout")
	
	var cooldownTimer = get_tree().create_timer(heavyAttackCooldown)
	cooldownTimer.connect("timeout", self, "on_heavy_attack_cooldown_complete")
	
	face_horizontal((get_global_mouse_position() - global_position).normalized())

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
		face_horizontal(velocity)
		
	move_and_slide(velocity * (movementSpeed + buffs["movement_speed"]))
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
			
				
func take_damage(value):
	if (!(buffs["dodge_chance"] > randf())):
		set_health(health - value)
		$"Hurtbox/CollisionShape2D".set_deferred("disabled", true)
		var timer = get_tree().create_timer(invulnerabilityPeriod + buffs["invulnerability_period"])
		timer.connect("timeout", self, "on_invulnerability_end")
	else:
		dodge()

func dodge():
	pass

func on_invulnerability_end():
	$"Hurtbox/CollisionShape2D".disabled = false

func pickup_item(item, cost):
	if (cost <= money):
		if (!item.has_method("can_pickup") || item.can_pickup(self)):
			item.on_pickup(self)
			set_money(money - cost)
			return true
	return false
	
func set_money(value):
	money = value
	emit_signal("money_changed", money)
	
func set_max_health(value):
	max_health = value
	emit_signal("max_health_changed", max_health)

func _on_Hurtbox_damage(source):
	print("somebody touch player hut box ")
	if("damage" in source):
		take_damage(source.damage)

