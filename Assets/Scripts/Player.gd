extends "res://Assets/Scripts/Mob.gd"

signal reset_level
signal spawn_destination_marker(position)
signal despawn_destination_marker


var starting_transform


func _init():
	starting_transform = transform


func _process(_delta):
	if transform.origin.y < Global.WORLD_FLOOR:
		reset_player()

		
func jump(_camera, event, click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if standing_on_ground and !jumping:
			reset_destination()
			velocity += get_jump_vector(click_position.y - transform.origin.y) \
					* jump_strenght
			jumping = true
			print(velocity)
		else:
			print("I can't jump in midair!")


func set_destination(new_destination):
	reset_destination()
	destination = new_destination
	emit_signal("spawn_destination_marker", destination)
	print(transform.origin)
	print(destination)


func reset_destination():
	destination = null
	last_distance_to_destination = 0
	last_angle_to_destination = 0
	speed = 0
	emit_signal("despawn_destination_marker")


func reset_player():
	transform = starting_transform
	reset_destination()
	velocity = Vector3.ZERO
	emit_signal("reset_level")
