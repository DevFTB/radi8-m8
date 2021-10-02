extends Node2D

export(float) var speed = 5
export(float) var attackPeriod = 3
export(float) var mutationPeriod = 10;

var attackTimer: float = 0.0
var mutationTimer: float = 0.0

var mutations = []
var activeMutations: Array
var inactiveMutations: Array
# Called when the node enters the scene tree for the first time.
func _ready():
	mutations = get_node("Mutations").get_children()
	
	activeMutations.append(mutations[0])
	inactiveMutations.append_array(mutations.slice(1, mutations.size()))
	for mut in inactiveMutations:
		print(mut)
		get_node("Mutations").remove_child(mut)
	
func _process(delta):
	attackTimer += delta
	mutationTimer += delta
	
	if(attackTimer > attackPeriod):
		attackTimer = 0.0
		attack();
		
	if(mutationTimer > mutationPeriod):
		mutationTimer = 0.0
		mutate();
		
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
		get_node("Mutations").add_child(newMutation)
		activeMutations.append(newMutation)
		inactiveMutations.remove(index)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
