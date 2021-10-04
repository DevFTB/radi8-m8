extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var radpodsLabelPath

onready var radpodsLabel = get_node(radpodsLabelPath)

# Called when the node enters the scene tree for the first time.
func _ready():
	update_ui()
	pass # Replace with function body.


func update_ui():
	radpodsLabel.set_text(str(get_node("/root/Global").radpods))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_consume_resource():
	update_ui()
	pass # Replace with function body.
