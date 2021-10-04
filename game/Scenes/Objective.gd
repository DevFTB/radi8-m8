extends StaticBody2D

export (int) var id
export (NodePath) var prompt

var currentAmount = 0
var playerInside = false

signal consume_resource

# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()
	pass # Replace with function body.


func update_text():
	if(Global.objective_data[id][0] < Global.objective_data[id][1]):
		$Node2D/Label.set_text(str(Global.objective_data[id][0]) + " out of " + str(Global.objective_data[id][1]))
	else:
		$Node2D/Label.set_text("Completed")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(playerInside and Input.is_action_just_pressed("interact")):
		consume()
		print("consume")
	pass

func consume():
	Global.consume_radpods(id)
	update_text()
	emit_signal("consume_resource")

func _on_body_entered(body):
	if(body.name == "HideoutPlayer"):
		print("area entered")
		playerInside = true
		if(prompt):
			get_node(prompt).set_visible(true)
		pass # Replace with function body.


func _on_body_exited(body):
	if(body.name == "HideoutPlayer"):
		playerInside = false
		if(prompt):
			get_node(prompt).set_visible(false)
	pass # Replace with function body.
