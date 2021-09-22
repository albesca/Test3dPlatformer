extends KinematicBody


export var acceleration_factor = 20.0
export var angle_precision = 0.05
export var distance_precision = 1.0
export var height = 1.0
export var jump_strenght = 10.0
export var jump_min_impulse = 0.25
export var jump_max_impulse = 0.75
export var speed_precision = 0.01
export var turning_speed = 5.0
export var walking_speed = 10.0

var destination = null
var destination_far = false
var jump_impulse = null
var last_distance_to_destination = 0
var last_angle_to_destination = 0
var mob_state
var speed = 0
var velocity = Vector3.ZERO


func get_jump_vector(jump_factor):
	var jump_angle = acos(clamp(jump_factor / height, jump_min_impulse, \
			jump_max_impulse))
	var result = transform.basis.z.rotated(transform.basis.x, -jump_angle)
	return result


func evaluate_state():
	if is_on_ground():
		mob_state = Global.STATE_ON_GROUND
	else:
		if velocity.y > 0:
			mob_state = Global.STATE_JUMPING
		else:
			mob_state = Global.STATE_FALLING


func is_on_ground():
	return is_on_floor()


func get_angle_to_target(target):
	var target_transform = transform.looking_at(target, Vector3.UP)
	var starting_rotation = transform.rotated(Vector3.UP, PI).basis.get_euler().y
	var target_rotation = target_transform.basis.get_euler().y
	var angle_to_target = target_rotation - starting_rotation
	if abs(angle_to_target) > PI:
		angle_to_target = (2 * PI - abs(angle_to_target)) * \
				(abs(angle_to_target) / angle_to_target) * -1
	return angle_to_target


func get_angle_rotation(angle_to_target, distance, delta):
	var speed_factor = clamp(speed, 1, walking_speed)
	var rotating_factor = clamp(turning_speed * (abs(angle_to_target) / PI) * \
			speed_factor, turning_speed * \
			Global.MIN_ROTATING_SPEED, turning_speed)
	var distance_factor = cos(clamp(abs(distance - distance_precision), 0, \
			PI / 2)) * 3
	if distance < distance_precision and !destination_far:
		rotating_factor *= 1 + distance_factor

	var result = clamp(abs(angle_to_target) * rotating_factor * \
			delta, 0, abs(angle_to_target)) * (angle_to_target / \
			abs(angle_to_target))
	return result


func get_destination_same_altitude(target):
	var result = Vector3(target)
	result.y = transform.origin.y
	return result


func is_getting_closer(distance_to_destination):
	var result = false
	if last_distance_to_destination == 0 or velocity == Vector3.ZERO:
		result = true
	elif distance_to_destination < last_distance_to_destination:
		result = true
	
	return result


func get_ground_normal():
	var result = Vector3.ZERO
	if is_on_floor():
		result = get_floor_normal()
		
	return result


func get_angle_precision(_distance):
	return angle_precision


func reset_destination():
	destination = null
	destination_far = false
	last_distance_to_destination = 0
	last_angle_to_destination = 0
	speed = 0


func _physics_process(delta):
	evaluate_state()
	if mob_state == Global.STATE_ON_GROUND:
		var is_braking = false
		velocity.y = 0
		if destination:
			var distance_to_destination = transform.origin.distance_to(\
					get_destination_same_altitude(destination))

			var angle_to_target = get_angle_to_target(\
					get_destination_same_altitude(destination))
			if abs(angle_to_target) > get_angle_precision( \
					distance_to_destination):
				var angle_rotation = get_angle_rotation(angle_to_target, \
						distance_to_destination, delta)
				rotate_y(angle_rotation)

			if distance_to_destination > distance_precision:
				if is_getting_closer(distance_to_destination):
					last_distance_to_destination = distance_to_destination
					speed = clamp(speed + acceleration_factor * delta * \
							cos(angle_to_target), 0, walking_speed * \
							abs(cos(angle_to_target)))
					var movement_direction = transform.basis.z
					var ground_normal = get_ground_normal()
					if ground_normal != Vector3.ZERO:
						var angle_to = transform.basis.y.angle_to(\
								ground_normal)
						if (angle_to > 0 + Global.DEFAULT_PRECISION) :
							var axis = transform.basis.y.cross(ground_normal)
							if axis != Vector3.ZERO and axis.length() != 0:
								movement_direction = movement_direction.rotated(
									axis.normalized(), angle_to
								)

					velocity = movement_direction * speed
				else:
					is_braking = true
			else:
				if destination_far or abs(angle_to_target) < \
						get_angle_precision(distance_to_destination) or ( \
						last_distance_to_destination < \
						distance_to_destination and \
						last_distance_to_destination != 0) or \
						(last_angle_to_destination != 0 and abs( \
						angle_to_target) > abs(last_angle_to_destination)):
					reset_destination()
				else:
					is_braking = true

			last_angle_to_destination = angle_to_target
		else:
			is_braking = true

		if is_braking:
			var drag = clamp(Global.DRAG_FACTOR * delta, 0, 1)
			velocity += -velocity * drag
			if velocity.length() < speed_precision:
				velocity = Vector3.ZERO

	else:
		var fall_factor = 1.0
		if velocity.y < Global.FALL_THRESHOLD:
			fall_factor = Global.FALL_FACTOR
		velocity.y = clamp(velocity.y - Global.GRAVITY_FACTOR * delta * \
				fall_factor, -Global.GRAVITY_FACTOR * fall_factor, velocity.y)

	if jump_impulse:
		velocity += jump_impulse
		jump_impulse = null

	if velocity != Vector3.ZERO:
		velocity = move_and_slide(velocity, Vector3.UP)
