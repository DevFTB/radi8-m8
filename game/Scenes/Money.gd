extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var money = 0 setget set_money
var rads = 0 setget set_rads
onready var player = get_parent().player
# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("money_changed", self, "set_money")
	player.connect("rads_changed", self, "set_rads")
	set_money(player.money)
	set_rads(player.rads)

func set_money(value):
	money = value
	$Label.text = str(money)
	
func set_rads(value):
	rads = value
	$Label2.text = str(rads)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

