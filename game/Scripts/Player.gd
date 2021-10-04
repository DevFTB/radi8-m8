extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal health_changed(health)
signal max_health_changed(max_health)
signal no_health
signal door_collision(tile_index)
signal money_changed(money)
signal buff_applied(buff_name)

export var attackInterval = 0.5

export var movementSpeed : int = 300
var currMovementSpeed : int
export var shootMovementSpeed : int = 200
export var dashSpeed : int = 1000
export var heavyAttackCooldown : float = 6
export var damage : int = 10
export var dashCooldown : float = 1.8
export var invulnerabilityPeriod = 1
export var money = 0
export var rads = 1

var rng = RandomNumberGenerator.new()


export (PackedScene) var bullet
var velocity : Vector2 = Vector2()
var facingLeft : bool = false;
export var dashDuration = 0.4;

export (Array, String) var door_tilenames = ["backdoor", "frontdoor", "leftdoor", "rightdoor"] 
var buffs = {"max_health": 0, "dodge_chance": 0, "invulnerability_period": 0, "movement_speed": 0, "attack_interval": 0}


var dashDir = Vector2()

enum {
	IDLE,
	MOVE,
	DASH,
	ATTACK,
	HEAVY_ATTACK,
	STOP
}
var state = IDLE
var canAttack = true
var canDash = true
var canHeavyAttack = true
var isInvulnerable = false

export(int) var max_health = 10
var health = null setget set_health

onready var animator: AnimationNodeStateMachinePlayback = get_node("AnimationTree").get("parameters/playback")

export (AudioStream) var runSound
export (AudioStream) var dashSound
export (AudioStream) var hurtSound
export (AudioStream) var attackSound
export (AudioStream) var heavyAttackSound
export (AudioStream) var healSound

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
			play_sound(runSound)
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
	if(!state == STOP):
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
		ATTACK:
			currMovementSpeed = shootMovementSpeed 
			move_process(delta)
			attack_process(delta)
			
			if(state != IDLE and canAttack and canHeavyAttack):
				transition(IDLE)
				
		HEAVY_ATTACK:
#			attack_process(delta)
			if(state != IDLE and (canHeavyAttack || canAttack)):
				transition(IDLE)
		DASH:
			dash_process(delta)
		STOP:
			pass

func idle_process(delta):
	if ($PlayerSound.playing):
		$PlayerSound.stop()
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
		
	play_sound(attackSound)
		
	canAttack = false
	var b = bullet.instance()
	b.fire_direction = (get_global_mouse_position() - $Sprite/FirePosition.global_position).normalized()
	face_horizontal(b.fire_direction)

	b.add_damage(Global.get_damage_buff())

	owner.add_child(b)
	b.set_position($Sprite/FirePosition.global_position)

	b.rotation = (get_global_mouse_position() - $Sprite/FirePosition.global_position).normalized().angle()
	var cooldownTimer = get_tree().create_timer(attackInterval + buffs["attack_interval"])
	cooldownTimer.connect("timeout", self, "on_attack_cooldown_complete")
	

	
func toggle_facing():
		$Sprite.scale.x = $Sprite.scale.x * -1
		facingLeft = !facingLeft;
		
func face_horizontal(dir):
	if((dir.x < 0 && !facingLeft) || (dir.x > 0 && facingLeft)):
		toggle_facing()
		
func perform_heavy_attack():
	transition(HEAVY_ATTACK)
	
	canHeavyAttack = false
	canAttack = false
	
	play_sound(heavyAttackSound)

	for x in range(5):
		var b = bullet.instance()
		b.fire_direction = (get_global_mouse_position() - $Sprite/FirePosition.global_position).rotated(rng.randf_range(-0.3, 0.3)).normalized()
		face_horizontal((get_global_mouse_position() - global_position).normalized())
		
		owner.add_child(b)
		b.set_position($Sprite/FirePosition.global_position)

		b.rotation = (get_global_mouse_position() - position).normalized().angle()
		yield(get_tree().create_timer(0.05), "timeout")
	
	var cooldownTimer = get_tree().create_timer(heavyAttackCooldown)
	cooldownTimer.connect("timeout", self, "on_heavy_attack_cooldown_complete")
	var cooldownTimer2 = get_tree().create_timer(attackInterval + buffs["attack_interval"])
	cooldownTimer2.connect("timeout", self, "on_attack_cooldown_complete")
	


func on_attack_cooldown_complete():
	canAttack = true

	
func on_heavy_attack_cooldown_complete():
	canHeavyAttack = true
	
func on_dash_cooldown_complete():
	canDash = true
	
func on_dash_complete():
	$"Hurtbox/CollisionShape2D".disabled = false
	transition(MOVE)	
	
func move_process(delta):
	if(state != ATTACK):
		face_horizontal(velocity)
		
	move_and_slide(velocity * (movementSpeed + buffs["movement_speed"]))
	check_collisions()
	
func set_health(value):
	if(health - value < 0):
		play_sound(healSound)
		
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", value)

	if (health == 0):
		emit_signal("no_health")
		stop()

func stop():
	transition(STOP)

func perform_dash():
	transition(DASH)
	play_sound(dashSound)
	canDash = false
	dashDir = get_input_direction();
	$"Hurtbox/CollisionShape2D".set_deferred("disabled", true)
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
			
				
func take_damage(value):
	if (!isInvulnerable):
		if (!(buffs["dodge_chance"] > randf())):
			$Camera2D.add_trauma(0.5)
			play_sound(hurtSound)
			set_health(health - value)
			invulnerability_start()
			
			var timer = get_tree().create_timer(invulnerabilityPeriod + buffs["invulnerability_period"])
			timer.connect("timeout", self, "on_invulnerability_end")
		else:
			dodge()

func dodge():
	pass

func on_invulnerability_end():
	$Tween.stop_all()
	$"Hurtbox/CollisionShape2D".disabled = false
	if (isInvulnerable): isInvulnerable = false
	
func invulnerability_start():
	$Tween.stop_all()
	$"Hurtbox/CollisionShape2D".set_deferred("disabled", true)
	if (!isInvulnerable): isInvulnerable = true
	tween_invulnerability_start()


func tween_invulnerability_start():
	if ($Tween.is_active()): return
	$Tween.start()
	
	$Tween.interpolate_property($Sprite, "modulate", 
	Color(1, 1, 1, 1), Color(1, 1, 1, 0.3), 0.2, 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	yield($Tween, "tween_completed")
	
	$Tween.interpolate_property($Sprite, "modulate", 
	Color(1, 1, 1, 0.3), Color(1, 1, 1, 1), 0.2, 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	yield($Tween, "tween_completed")
	
	if (isInvulnerable): tween_invulnerability_start()
	

func pickup_item(item, cost):
	if (cost <= money):
		if (!item.has_method("can_pickup") || item.can_pickup(self)):
			item.on_pickup(self)
			set_money(money - cost)
			var buff_name = ""
			if ("buff_name" in item):
				buff_name = item.buff_name
			emit_signal("buff_applied", buff_name)
			return true
	return false
	
func set_money(value):
	money = value
	emit_signal("money_changed", money)
	
# for hideout objective
func add_max_health(value):
	print("adding max health")
	max_health += value
	health = max_health
	emit_signal("max_health_changed", max_health)
	
func set_max_health(value):
	max_health = value
	emit_signal("max_health_changed", max_health)

func _on_Hurtbox_damage(source):
	if("damage" in source):
		take_damage(source.damage)

func play_sound(audio):
	$PlayerSound.set_stream(audio)
	$PlayerSound.play()
