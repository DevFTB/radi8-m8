extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var radpodsLabelPath
export (NodePath) var medsLabelPath

onready var radpodsLabel = get_node(radpodsLabelPath)
onready var medsLabel = get_node(medsLabelPath)
# Called when the node enters the scene tree for the first time.
func _ready():
	update_ui()
	pass # Replace with function body.


func update_ui():
	radpodsLabel.set_text(str(get_node("/root/Global").radpods))
	medsLabel.set_text(str(get_node("/root/Global").meds))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HideoutPlayer_consume_resource():
	update_ui()
	pass # Replace with function body.
