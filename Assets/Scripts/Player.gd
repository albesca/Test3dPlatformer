extends KinematicBody

signal reset_level
signal spawn_destination_marker(position)
signal despawn_destination_marker

const HEIGHT = 2.0
const DRAG_FACTOR = 100.0
const GRAVITY_FACTOR = 10.0
const FALL_THRESHOLD = -0.5
const FALL_FACTOR = 4.0
const MIN_ROTATING_SPEED = 0.25
const WORLD_FLOOR = -20.0
export var rotating_speed = 5.0
export var walking_speed = 10.0
export var acceleration_factor = 20.0
export var running_factor = 2.0
export var jump_strenght = 10.0
export var angle_precision = 0.05
export var max_angle_to_move = PI / 4.0
export var distance_precision = 1
export var speed_precision = 0.01
var velocity = Vector3.ZERO
var destination = null
var running = false
var jumping
var speed = 0
var last_distance_to_destination = 0
var last_angle_to_destination = 0
var starting_transform
var standing_on_ground


func _init():
	starting_transform = transform


func _process(_delta):
	if transform.origin.y < WORLD_FLOOR:
		reset_player()

		
func _physics_process(delta):
	standing_on_ground = !jumping and (is_on_floor() or \
			$GroundDetector.is_colliding())
	transform = transform.orthonormalized()
	if velocity != Vector3.ZERO:
		velocity = move_and_slide(velocity, Vector3.UP)
		if is_on_floor():
			jumping = false
	
	if destination and standing_on_ground:
		var angle_to_target = get_angle_to_target(destination)
		if abs(angle_to_target) > angle_precision and \
					(last_angle_to_destination == 0 or abs(angle_to_target) <= \
					abs(last_angle_to_destination)):

			var angle_rotation = get_angle_rotation(angle_to_target, delta)
			rotate_y(angle_rotation)

		var distance_to_destination = 0
		if destination:
			distance_to_destination = transform.origin.distance_to(destination)

		if distance_to_destination > distance_precision and \
				is_getting_closer(distance_to_destination):

			last_distance_to_destination = distance_to_destination
			if abs(angle_to_target) < max_angle_to_move:
				var applied_acceleration = acceleration_factor
				if angle_to_target > PI / 2.0 and velocity.length() > \
						speed_precision:
					applied_acceleration = DRAG_FACTOR * -1
				speed = clamp(speed + applied_acceleration * delta, 0, \
						walking_speed)
				velocity = transform.basis.z * speed

		else:
			if abs(angle_to_target) < angle_precision or \
					(last_distance_to_destination < distance_to_destination \
					and last_distance_to_destination != 0) or \
					(last_angle_to_destination != 0 and abs(angle_to_target) > \
					abs(last_angle_to_destination)):
				reset_destination()

		last_angle_to_destination = angle_to_target

	if standing_on_ground:
		velocity.y = 0
		if !destination:
			if velocity.z != 0:
				velocity.z = clamp(abs(velocity.z) - DRAG_FACTOR * delta, 0, \
						abs(velocity.z)) * (abs(velocity.z) / velocity.z)
			if velocity.x != 0:
				velocity.x = clamp(abs(velocity.x) - DRAG_FACTOR * delta, 0, \
						abs(velocity.x)) * (abs(velocity.x) / velocity.x)
			
			if abs(velocity.z) < speed_precision:
				velocity.z = 0
			if abs(velocity.x) < speed_precision:
				velocity.x = 0

	else:
		var fall_factor = 1.0
		if velocity.y < FALL_THRESHOLD:
			fall_factor = FALL_FACTOR
		velocity.y = clamp(velocity.y - GRAVITY_FACTOR * delta * fall_factor, \
				-GRAVITY_FACTOR * fall_factor, velocity.y)


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


func get_jump_vector(jump_factor):
	var jump_angle = acos(clamp(jump_factor / HEIGHT, 0.25, 0.75))
	var result = transform.basis.z.rotated(transform.basis.x, -jump_angle)
	return result


func get_angle_to_target(target):
	var target_transform = transform.looking_at(target, Vector3.UP)
	var starting_rotation = transform.rotated(Vector3.UP, PI).basis.get_euler().y
	var target_rotation = target_transform.basis.get_euler().y
	var angle_to_target = target_rotation - starting_rotation
	if abs(angle_to_target) > PI:
		angle_to_target = (2 * PI - abs(angle_to_target)) * \
				(abs(angle_to_target) / angle_to_target) * -1
	return angle_to_target


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


func is_getting_closer(distance_to_destination):
	var result = false
	if last_distance_to_destination == 0:
		result = true
	elif velocity == Vector3.ZERO:
		result = true
	elif distance_to_destination < last_distance_to_destination:
		result = true
	elif distance_to_destination > distance_precision * 2:
		result = true
	
	return result


func get_angle_rotation(angle_to_target, delta):
	var rotating_factor = clamp(rotating_speed * (abs(angle_to_target) / PI), \
			rotating_speed * MIN_ROTATING_SPEED, rotating_speed)
	var result = clamp(abs(angle_to_target) * rotating_factor * \
			delta, 0, abs(angle_to_target)) * (angle_to_target / \
			abs(angle_to_target))
	return result


func reset_player():
	transform = starting_transform
	reset_destination()
	velocity = Vector3.ZERO
	emit_signal("reset_level")
