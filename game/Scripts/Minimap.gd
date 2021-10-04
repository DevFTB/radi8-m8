extends Control

export (NodePath) var room_controller_path
export (int) var room_padding = 0
export (Texture) var room_square
export (Array, Texture) var room_doors
export (Array, Texture) var room_doors_new
export (Texture) var cross
enum direction {UP, RIGHT, DOWN, LEFT}

onready var room_controller = get_node(room_controller_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	var width = rect_size[0]
	var height = rect_size[1]
	var n_rooms = room_controller.get_max_room() + 1
	var room_width = (width - ((n_rooms - 1) * room_padding))/n_rooms
	var room_height = (height - ((n_rooms - 1) * room_padding))/n_rooms
	draw_set_transform(Vector2(0, height), 0, Vector2.ONE)
#	draw_rect(Rect2(Vector2.ONE * 100, Vector2.ONE * 100), "#FFFFFF")

	var current_y
	var current_x = 0
	for i in range(0, n_rooms):
		current_y = -room_height
		for j in range(0, n_rooms):
			var draw_rect = Rect2(current_x, current_y, room_width, room_height)
			if room_controller.room.has([i, j]) and room_controller.room[[i, j]].visited:
				draw_texture_rect(room_square, draw_rect, false)
#				draw_room_icon(x, y, width, height)
			current_y -= room_padding + room_height
		current_x += room_padding + room_width
	
	current_x = 0
	print(room_controller.get_neighbours(room_controller.current_room))
	for i in range(0, n_rooms):
		current_y = -room_height
		for j in range(0, n_rooms):
			var draw_rect = Rect2(current_x, current_y, room_width, room_height)
			var draw_right_rect = Rect2(current_x + room_width, current_y, room_width, room_height)
			var draw_up_rect = Rect2(current_x, current_y - room_height, room_width, room_height)
			
#			if(room_controller.connection_exists([i, j], [i+1, j])):
#				draw_texture_rect(room_doors_new[direction.RIGHT], draw_rect, false)
#				draw_texture_rect(room_doors_new[direction.LEFT], draw_right_rect, false)
#			if(room_controller.connection_exists([i, j], [i, j+1])):
#				draw_texture_rect(room_doors[direction.UP], draw_rect, false)
#				draw_texture_rect(room_doors[direction.DOWN], draw_up_rect, false)
			
			if (room_controller.room.has([i, j]) and room_controller.room[[i, j]].visited) or (room_controller.room.has([i + 1, j]) and room_controller.room[[i + 1, j]].visited):
				var removed = room_controller.connection_removed([i, j], [i+1, j])
	#			var colour
	#			var draw = false
				if(room_controller.connection_added([i, j], [i+1, j]) and not removed):
					draw_texture_rect(room_doors_new[direction.RIGHT], draw_rect, false)
					draw_texture_rect(room_doors_new[direction.LEFT], draw_right_rect, false)
				elif(room_controller.connection_exists([i, j], [i+1, j])):
					draw_texture_rect(room_doors[direction.RIGHT], draw_rect, false)
					draw_texture_rect(room_doors[direction.LEFT], draw_right_rect, false)
				elif(removed):
					pass
	#				colour = "#FF0000"
	#				draw = true
#
#			draw = false
			if (room_controller.room.has([i, j]) and room_controller.room[[i, j]].visited) or (room_controller.room.has([i, j + 1]) and room_controller.room[[i, j + 1]].visited):
				var removed = room_controller.connection_removed([i, j], [i, j+1])
				if(room_controller.connection_added([i, j], [i, j + 1]) and not removed):
					draw_texture_rect(room_doors_new[direction.RIGHT], draw_rect, false)
					draw_texture_rect(room_doors_new[direction.LEFT], draw_right_rect, false)
				elif(room_controller.connection_exists([i, j], [i, j+1])):
					draw_texture_rect(room_doors[direction.UP], draw_rect, false)
					draw_texture_rect(room_doors[direction.DOWN], draw_up_rect, false)
				elif(removed):
					pass
	#				colour = "#FF0000"
	#				draw = true
#	#			if draw:
#	#				draw_rect(Rect2(current_x, current_y - room_height, room_width, -room_padding), colour)
				
			current_y -= room_padding + room_height
		
		current_x += room_padding + room_width
		

	
	
