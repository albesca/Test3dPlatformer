extends "res://Assets/Scripts/Mob.gd"

signal reset_level
signal spawn_destination_marker(position)
signal despawn_destination_marker


var starting_transform
var obstructing_bodies = []


func _init():
	starting_transform = transform


func _ready():
	set_cameras_raycasts()


func _process(_delta):
	if transform.origin.y < Global.WORLD_FLOOR:
		reset_player()

		
func is_on_ground():
	return is_on_floor() or $GroundDetector.is_colliding()


func get_ground_normal():
	var result = Vector3.ZERO
	if is_on_floor():
		result = get_floor_normal()
	elif $GroundDetector.is_colliding():
		result = $GroundDetector.get_collision_normal()
		
	return result


func check_distance():
	var distance = transform.origin.distance_to(destination)
	if distance > distance_precision * 2.0:
		destination_far = true


func jump(_camera, event, click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if mob_state == Global.STATE_ON_GROUND:
			reset_destination()
			jump_impulse = get_jump_vector(click_position.y - \
					transform.origin.y) * jump_strenght


func get_angle_precision(distance):
	var distance_factor = cos(clamp(abs(distance - distance_precision), 0, \
			PI / 2)) * 3
	return angle_precision * (1 + distance_factor)


func set_destination(new_destination):
	reset_destination()
	destination = new_destination
	check_distance()
	emit_signal("spawn_destination_marker", destination)
	print(transform.origin)
	print(destination)


func reset_destination():
	if destination:
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


func set_cameras_raycasts():
	$BackCamera.set_raycasts(global_transform.origin + Vector3(0, 2, 0), \
			global_transform.origin + Vector3(0, 0.1, 0))
	$FrontCamera.set_raycasts(global_transform.origin + Vector3(0, 2, 0), \
			global_transform.origin + Vector3(0, 0.1, 0))
	$LeftCamera.set_raycasts(global_transform.origin + Vector3(0, 2, 0), \
			global_transform.origin + Vector3(0, 0.1, 0))
	$RightCamera.set_raycasts(global_transform.origin + Vector3(0, 2, 0), \
			global_transform.origin + Vector3(0, 0.1, 0))


func potential_obstruction_entered(body):
	body.check_obstruction = true
	if !body in obstructing_bodies:
		obstructing_bodies.append(body)

	set_camera_raycasts_active()


func potential_obstruction_exited(body):
	body.check_obstruction = false
	var body_index = obstructing_bodies.find(body)
	if body_index > -1:
		obstructing_bodies.remove(body_index)
	
	if len(obstructing_bodies) == 0:
		set_camera_raycasts_inactive()


func set_camera_raycasts_active():
	$BackCamera.raycast_active = true
	$FrontCamera.raycast_active = true
	$LeftCamera.raycast_active = true
	$RightCamera.raycast_active = true


func set_camera_raycasts_inactive():
	$BackCamera.raycast_active = false
	$FrontCamera.raycast_active = false
	$LeftCamera.raycast_active = false
	$RightCamera.raycast_active = false
