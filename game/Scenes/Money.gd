extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var money = 0 setget set_money
onready var player = get_parent().player
# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("money_changed", self, "set_money")
	set_money(player.money)

func set_money(value):
	money = value
	$Label.text = str(money)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

