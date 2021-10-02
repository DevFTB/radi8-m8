xtends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal health_changed
signal no_health

export var movementSpeed : int = 500
export var damage : int = 10
var velocity : Vector2 = Vector2()
var directionFacing : Vector2 = Vector2()

export(int) var max_health = 4
onready var health = 2 setget set_health




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _physics_process(delta):
	velocity = Vector2(0, 0)
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		directionFacing.y = -1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		directionFacing.y = 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1 
		directionFacing.x = -1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		directionFacing.x = 1
	
	velocity = velocity.normalized()
	move_and_slide(velocity * movementSpeed)




func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed")
	if (health == 0):
		emit_signal("no_health")
