extends KinematicBody2D

signal health_changed
signal no_health

export(float) var speed = 40
export(float) var attackPeriod = 3
export(float) var mutationPeriod = 10
export(int) var max_health = 5
export(int) var engagementRadius = 100
export (NodePath) var playerPath

onready var navigation = get_parent().room
onready var player = get_node(playerPath)

onready var health = max_health setget set_health

var path = null
var velocity = Vector2.ZERO

var attackTimer: float = 0.0
var mutationTimer: float = 0.0

var mutations = []
var activeMutations: Array
var inactiveMutations: Array
enum {
	LEFT,
	RIGHT
}

var horizontal_dir = LEFT
# Called when the node enters the scene tree for the first time.

func _ready():
	print(get_children())
	mutations = $Mutations.get_children()
	
	activeMutations.append(mutations[0])
	
	if(activeMutations[0].has_method("set_player")):
			print("set player")
			activeMutations[0].set_player(player)
	
	inactiveMutations.append_array(mutations.slice(1, mutations.size()))

	for mut in inactiveMutations:
		print(mut)
		$Mutations.remove_child(mut)
	
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
	navigation = get_parent().room
	
	if(player and navigation):
		genPath()
		navigate()
		turn()
	move()
		
func attack():
	var index = randi() % activeMutations.size()
	var mutation = activeMutations[index]
	

	if(mutation.has_method("attack")):
		mutation.attack()
		
func mutate():

	if (activeMutations.size() < mutations.size()):
		var index = randi() % inactiveMutations.size()
		var newMutation = inactiveMutations[index]
		$Mutations.add_child(newMutation)
		
		if(newMutation.has_method("set_player")):
			print("set player")
			newMutation.set_player(player)
			
		if(newMutation.has_method("set_owner")):
			print("set owner")
			newMutation.set_owner(self)
		
		activeMutations.append(newMutation)
		inactiveMutations.remove(index)

func genPath():
	if(navigation != null and player != null):
		path = navigation.get_simple_path(get_global_position(), player.get_global_position())
		
func navigate():
	if (path.size() > 0):
		velocity = global_position.direction_to(path[1]) * speed
		
		if global_position == path[0]:
			path.remove(0)
			
func set_move_speed(multiplier):
	speed *= multiplier;

func move():
	if(!((global_position + velocity) - player.get_global_position()).length() < engagementRadius):
		velocity = move_and_slide(velocity)
	
func take_damage(value):
	set_health(health - value)

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
	queue_free()

func turn():
	var angle = global_position.angle_to_point(player.global_position)
	if abs(angle) > PI/2:
		if (horizontal_dir == LEFT):
			scale.x = -1
			horizontal_dir = RIGHT
	else:
		if (horizontal_dir == RIGHT):
			scale.x = -1
			horizontal_dir = LEFT
