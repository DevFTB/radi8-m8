extends Node

var radpods = 0

var hideout = "res://Scenes/Hideout.tscn";

# max amnt, factor

var objective_data = {
	0: [0, 10, 10], # health
	1: [0, 8, 8], # mutation
	2: [0, 8, 2] # damage
}

func add_radpods(amount):
	radpods += amount

func consume_radpods(id):
	if (radpods > 0 and (objective_data[id][0] < objective_data[id][1])):
		objective_data[id][0] += 1
		radpods -= 1
	
	pass
		

func get_damage_buff():
	var id = 2
	return (objective_data[id][0] / objective_data[id][1]) * objective_data[id][2]
	
func get_mutation_buff():
	var id = 0
	return (objective_data[id][0] / objective_data[id][1]) * objective_data[id][2]

func get_health_buff():
	var id = 1
	return (objective_data[id][0] / objective_data[id][1]) * objective_data[id][2]

func load_hideout(player):
#	get_parent().get_node("Node2D4").queue_free()
	add_radpods(player.rads)
	get_tree().change_scene(hideout)
