extends Control

export (NodePath) var room_controller_path
export (int) var room_padding = 10
export (Color) var room_colour = "#000000"
export (Color) var connection_colour = "#FFFF00"

onready var room_controller = get_node(room_controller_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	var width = rect_size[0]
	var height = rect_size[1]
	var n_rooms = int(sqrt(len(room_controller.room.keys())))
	var room_width = (width - ((n_rooms - 1) * room_padding))/n_rooms
	var room_height = (height - ((n_rooms - 1) * room_padding))/n_rooms
	draw_set_transform(Vector2(0, height), 0, Vector2.ONE)
#	draw_rect(Rect2(Vector2.ONE * 100, Vector2.ONE * 100), "#FFFFFF")

	var current_y
	var current_x = 0
	
	for i in range(0, n_rooms):
		current_y = 0
		for j in range(0, n_rooms):
			draw_rect(Rect2(current_x, current_y, room_width, -room_height), room_colour)
			
#			if(room_controller.connection_exists([i, j], [i+1, j])):
#				draw_rect(Rect2(current_x + room_width, current_y, room_padding, -room_height), connection_colour)
#			if(room_controller.connection_exists([i, j], [i, j+1])):
#				draw_rect(Rect2(current_x, current_y - room_height, room_width, -room_padding), connection_colour)
			var removed = room_controller.connection_removed([i, j], [i+1, j])
			var colour
			var draw = false
			if(room_controller.connection_added([i, j], [i+1, j]) and not removed):
				colour = "#00FF00"
				draw = true
			elif(room_controller.connection_exists([i, j], [i+1, j])):
				colour = connection_colour
				draw = true
			elif(removed):
				colour = "#FF0000"
				draw = true
			if draw:
				draw_rect(Rect2(current_x + room_width, current_y, room_padding, -room_height), colour)

			removed = room_controller.connection_removed([i, j], [i, j+1])
			draw = false
			if(room_controller.connection_added([i, j], [i, j+1]) and not removed):
				colour = "#00FF00"
				draw = true
			elif(room_controller.connection_exists([i, j], [i, j+1])):
				colour = connection_colour
				draw = true
			elif(removed):
				colour = "#FF0000"
				draw = true
			if draw:
				draw_rect(Rect2(current_x, current_y - room_height, room_width, -room_padding), colour)
				
			current_y -= room_padding + room_height
		
		current_x += room_padding + room_width
		

	
	
