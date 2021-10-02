extends KinematicBody2D

signal health_changed
signal no_health

export(float) var speed = 40
export(float) var attackPeriod = 3
export(float) var mutationPeriod = 10
export(int) var max_health = 5
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
# Called when the node enters the scene tree for the first time.

func _ready():
	print(get_children())
	mutations = $Mutations.get_children()
	
	activeMutations.append(mutations[0])
	inactiveMutations.append_array(mutations.slice(1, mutations.size()))
	for mut in inactiveMutations:
		print(mut)
		$Mutations.remove_child(mut)
	
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
	move()
		
func attack():
	var index = randi() % activeMutations.size()
	var mutation = activeMutations[index]
	
	print("attempt an attack")
	if(mutation.has_method("attack")):
		mutation.attack()
		
func mutate():
	print("attempt mutations")
	if (activeMutations.size() < mutations.size()):
		print("mutate")
		var index = randi() % inactiveMutations.size()
		var newMutation = inactiveMutations[index]
		$Mutations.add_child(newMutation)
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

func move():
	velocity = move_and_slide(velocity)
	
func take_damage(value):
	set_health(health - value)

func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed")
	if (health == 0):
		emit_signal("no_health")
		queue_free()

func _on_Hurtbox_area_entered(area):
	take_damage(area.damage)

func die():
	queue_free()
