extends KinematicBody


var HEIGHT = 2.0
var last_distance_to_destination = 0
var last_angle_to_destination = 0
var velocity = Vector3.ZERO
var standing_on_ground
var jumping
var destination = null
var speed = 0
var running = false
export var angle_precision = 0.05
export var distance_precision = 1
export var rotating_speed = 5.0
export var max_angle_to_move = PI / 4.0
export var acceleration_factor = 20.0
export var speed_precision = 0.01
export var walking_speed = 10.0
export var running_factor = 2.0
export var jump_strenght = 10.0


func _physics_process(delta):
	standing_on_ground = !jumping and (is_on_floor() or \
			$GroundDetector.is_colliding())
	transform = transform.orthonormalized()
	if velocity != Vector3.ZERO:
		velocity = move_and_slide(velocity, Vector3.UP)
		if is_on_floor():
			jumping = false
	
	if destination and standing_on_ground:
		var angle_to_target = get_angle_to_target(\
				get_destination_same_altitude(destination))
		if abs(angle_to_target) > angle_precision and \
					(last_angle_to_destination == 0 or abs(angle_to_target) <= \
					abs(last_angle_to_destination)):

			var angle_rotation = get_angle_rotation(angle_to_target, delta)
			rotate_y(angle_rotation)

		var distance_to_destination = 0
		if destination:
			distance_to_destination = transform.origin.distance_to(\
					get_destination_same_altitude(destination))

		if distance_to_destination > distance_precision and \
				is_getting_closer(distance_to_destination):

			last_distance_to_destination = distance_to_destination
			if abs(angle_to_target) < max_angle_to_move:
				var applied_acceleration = acceleration_factor
				if angle_to_target > PI / 2.0 and velocity.length() > \
						speed_precision:
					applied_acceleration = Global.DRAG_FACTOR * -1
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
				velocity.z = clamp(abs(velocity.z) - Global.DRAG_FACTOR * \
						delta, 0, abs(velocity.z)) * (abs(velocity.z) / \
						velocity.z)
			if velocity.x != 0:
				velocity.x = clamp(abs(velocity.x) - Global.DRAG_FACTOR * \
						delta, 0, abs(velocity.x)) * (abs(velocity.x) / \
						velocity.x)
			
			if abs(velocity.z) < speed_precision:
				velocity.z = 0
			if abs(velocity.x) < speed_precision:
				velocity.x = 0

	else:
		var fall_factor = 1.0
		if velocity.y < Global.FALL_THRESHOLD:
			fall_factor = Global.FALL_FACTOR
		velocity.y = clamp(velocity.y - Global.GRAVITY_FACTOR * delta * \
				fall_factor, -Global.GRAVITY_FACTOR * fall_factor, velocity.y)


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
			rotating_speed * Global.MIN_ROTATING_SPEED, rotating_speed)
	var result = clamp(abs(angle_to_target) * rotating_factor * \
			delta, 0, abs(angle_to_target)) * (angle_to_target / \
			abs(angle_to_target))
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


func get_jump_vector(jump_factor):
	var jump_angle = acos(clamp(jump_factor / HEIGHT, 0.25, 0.75))
	var result = transform.basis.z.rotated(transform.basis.x, -jump_angle)
	return result


func reset_destination():
	destination = null
	last_distance_to_destination = 0
	last_angle_to_destination = 0
	speed = 0


func get_destination_same_altitude(target):
	var result = Vector3()
	result.x = target.x
	result.z = target.z
	result.y = transform.origin.y
	return result
