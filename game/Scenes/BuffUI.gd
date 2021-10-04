extends HBoxContainer

export (Array, String) var buffs
export (Array, NodePath) var buff_elem_paths
var buff_elements = {}
onready var player = get_parent().player
 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	player.connect("buff_applied", self, "show_element")
	for i in range(0, buff_elem_paths.size()):
		buff_elements[buffs[i]] = get_node(buff_elem_paths[i])
	for element in buff_elements.values():
		element.modulate.a = 0.25


# Called when the node enters the scene tree for the first time.
func show_element(element):
	if element in buff_elements:
		buff_elements[element].modulate.a = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
