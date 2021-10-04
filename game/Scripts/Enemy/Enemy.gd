extends KinematicBody2D

signal health_changed
signal no_health

export(float) var speed = 40
export(float) var attackPeriod = 3
export(float) var mutationPeriod = 10
export(int) var max_health = 5
export(int) var defaultEngagementRadius = 170
export(float) var dispersion_factor = 30
export(float) var coin_drop_chance = 0.3
export(int) var aggro_range = 1600

export (PackedScene) var deathSplosion
export (PackedScene) var coin
export (NodePath) var playerPath
var movementSpeedModifier = 1

export (Array, AudioStream) var hurtSounds
export (AudioStream) var deathSound

onready var navigation = get_parent().room
var player

onready var health = max_health setget set_health

var path = null
var velocity = Vector2.ZERO

var attackTimer: float = 0.0
var mutationTimer: float = 0.0

onready var engagementRadius = defaultEngagementRadius

var mutations = []
var activeMutations: Array = []
var passiveMutations: Array = []
var unequippedMutations: Array
enum {
	LEFT,
	RIGHT
}

var enemies
var aggro = false

var horizontal_dir = LEFT
# Called when the node enters the scene tree for the first time.

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemy")
	print(get_children())
	mutations = $Mutations.get_children()
	
	unequippedMutations.append_array(mutations)
	
	for mut in unequippedMutations:
		print(mut)
		$Mutations.remove_child(mut)
		
	mutate()
	$Hurtbox.connect("damage", self, "_on_Hurtbox_damage")
	$Hurtbox.connect("area_entered", self, "_on_Hurtbox_damage")
	
func _process(delta):
	attackTimer += delta
	mutationTimer += delta
	
	if(attackTimer > attackPeriod):
		attackTimer = 0.0
		attack();
		
	if(mutationTimer > mutationPeriod):
		mutationTimer = 0.0
		mutate();

func _physics_process(delta):
	if (aggro):
		navigation = get_parent().room
		
		if(player and navigation):
			genPath()
			navigate()
		turn()
		move()
	if (!aggro and get_global_position().distance_to(player.get_global_position()) < aggro_range):
		aggro = true
		
func attack():
	if(activeMutations.size() > 0):
		var index = randi() % activeMutations.size()
		var mutation = activeMutations[index]

		if(mutation.has_method("attack")):
			mutation.attack()
			if ("engagementRadius" in mutation):
				engagementRadius = mutation.engagementRadius 
			else:
				engagementRadius = defaultEngagementRadius

func mutate():
	if (unequippedMutations.size() > 0):
		
		var sum = 0
		for mutation in mutations:
			sum += mutation.relativeProbability
			
		var rand = randi() % sum
		
		var bottom = 0 
		var index = 0
		for mutation in mutations:
			if ((rand > bottom and rand <= bottom + mutation.relativeProbability) or index == mutations.size() - 1):
				break
			else:
				index += 1
				bottom += mutation.relativeProbability
		
		var uneqIndex = unequippedMutations.find(mutations[index])
		
		if (uneqIndex >= 0):
			var newMutation = mutations[index]
			$Mutations.call_deferred("add_child", newMutation)

			if(newMutation.has_method("set_player")):
				print("set player")
				newMutation.set_player(player)
				
			if(newMutation.has_method("set_enemy")):
				print("set owner")
				newMutation.set_enemy(self)
				
			newMutation.equip() 
			
			if(newMutation.has_method("attack")):
				activeMutations.append(newMutation)
			else:
				passiveMutations.append(newMutation)
			
			unequippedMutations.remove(uneqIndex)

func genPath():
	if(navigation != null and player != null):
		path = navigation.get_simple_path(get_global_position(), player.get_global_position())

func navigate():
	if (path.size() > 0):
		velocity = global_position.direction_to(path[1]) * speed * movementSpeedModifier
		if global_position == path[0]:
			path.remove(0)

func set_move_speed(multiplier):
	movementSpeedModifier *= multiplier
	
func move():
	var distance_to_player = get_global_position().distance_to(player.get_global_position())
	var dispersion_velocity = get_dispersion_velocity()
	var dot_product = velocity.dot(dispersion_velocity)
	if (dot_product > 0):
		velocity += dispersion_velocity - dispersion_velocity.project(velocity)
	else:
		velocity += dispersion_velocity  
	
	if(distance_to_player > engagementRadius):
		velocity = move_and_slide(velocity)
	
func take_damage(value):
	var offset = 0
	
	for mutation in passiveMutations:
		if(mutation.has_method("offset_damage")):
			offset += mutation.offset_damage(value - offset)
	
	if(value - offset > 0):
		play_sound(hurtSounds[randi() % hurtSounds.size()])
		set_health(health - (value - offset))

func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed")
	if (health == 0):
		emit_signal("no_health")
		die()

func _on_Hurtbox_damage(area):
	if("damage" in area):
		take_damage(area.damage)

func die():
	play_sound(deathSound)
	var ins = deathSplosion.instance()
	get_tree().root.add_child(ins)
	if (randf() < coin_drop_chance):
		var drop = coin.instance()
		drop.position = position
		get_parent().get_node("Layout").call_deferred("add_child", drop)
	
	ins.set_global_position(self.global_position)
	ins.apply_scale(Vector2(abs(scale.x),abs(scale.y)))
	
	queue_free()

func turn():
	var angle = global_position.angle_to_point(player.global_position)
	if abs(angle) > PI/2:
		if (horizontal_dir == LEFT):
			$Sprite.set_flip_h(true)
			$Mutations.set_scale(Vector2(-1,1))
			horizontal_dir = RIGHT
	else:
		if (horizontal_dir == RIGHT):
			$Sprite.set_flip_h(false)
			$Mutations.set_scale(Vector2(1,1))
			horizontal_dir = LEFT
			
func play_sound(audio):
	$Sound.set_stream(audio)
	$Sound.play()

func get_dispersion_velocity():
	var result = Vector2()
	for enemy in enemies:
		if is_instance_valid(enemy) && enemy != self:
			var vector = get_global_position() - enemy.get_global_position()
			result += vector.normalized() * speed * dispersion_factor * 1/vector.length()
	return result

