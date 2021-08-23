extends KinematicBody


const HEIGHT = 2.0
const DRAG_FACTOR = 100.0
const GRAVITY_FACTOR = 10.0
const FALL_THRESHOLD = -0.5
const FALL_FACTOR = 4.0
export var rotating_speed = 5.0
export var walking_speed = 10.0
export var running_factor = 2.0
export var jump_strenght = 10.0
export var angle_precision = 0.05
export var max_angle_to_move = PI / 4.0
export var distance_precision = 1
export var speed_precision = 0.01
var velocity = Vector3.ZERO
var destination = null
var running = false
var speed = 0
var last_distance_to_destination = 0
var last_angle_to_destination = 0


func jump(_camera, event, click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if is_on_floor():
			reset_destination()
			velocity += get_jump_vector(click_position.y - transform.origin.y) \
					* jump_strenght
			print(velocity)
		else:
			#TODO add raycast to see if I'm actually in midair
			#TODO add a counter since last jump to avoid double jump
			print("I can't jump in midair!")


func get_jump_vector(jump_factor):
	var jump_angle = acos(clamp(jump_factor / HEIGHT, 0.25, 0.75))
	var result = transform.basis.z.rotated(transform.basis.x, -jump_angle)
	return result


func _physics_process(delta):
	transform = transform.orthonormalized()
	if velocity != Vector3.ZERO:
		velocity = move_and_slide(velocity, Vector3.UP)
	
	if destination and is_on_floor():
		var angle_to_target = get_angle_to_target(destination)
		if abs(angle_to_target) > angle_precision and \
					(last_angle_to_destination == 0 or abs(angle_to_target) <= \
					abs(last_angle_to_destination)):
			var angle_rotation = clamp(abs(angle_to_target) * rotating_speed * \
					delta, 0, abs(angle_to_target)) * (angle_to_target / \
					abs(angle_to_target))
			rotate_y(angle_rotation)

		var distance_to_destination = 0
		if destination:
			distance_to_destination = transform.origin.distance_to(destination)

		if distance_to_destination > distance_precision and \
				(distance_to_destination < last_distance_to_destination or \
				last_distance_to_destination == 0 or velocity == Vector3.ZERO):
			last_distance_to_destination = distance_to_destination
			if abs(angle_to_target) < max_angle_to_move:
				speed = clamp(speed + walking_speed * delta, 0, walking_speed)
				velocity = transform.basis.z * speed

		else:
			if abs(angle_to_target) < angle_precision or \
					(last_distance_to_destination < distance_to_destination \
					and last_distance_to_destination != 0) or \
					(last_angle_to_destination != 0 and abs(angle_to_target) > \
					abs(last_angle_to_destination)):
				reset_destination()

		last_angle_to_destination = angle_to_target

	if is_on_floor():
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


func get_angle_to_target(target):
	var target_transform = transform.looking_at(target, Vector3.UP)
	var starting_rotation = transform.rotated(Vector3.UP, PI).basis.get_euler().y
	var target_rotation = target_transform.basis.get_euler().y
	var angle_to_target = target_rotation - starting_rotation
	if abs(angle_to_target) > PI:
		angle_to_target = (2 * PI - abs(angle_to_target)) * \
				(abs(angle_to_target) / angle_to_target) * -1
	return angle_to_target


func are_basis_equal_ignore_axis(base_basis, target_basis, axis, precision):
	var base_x = round_vector3(base_basis.x, precision)
	var base_y = round_vector3(base_basis.y, precision)
	var base_z = round_vector3(base_basis.z, precision)
	var target_x = round_vector3(target_basis.x, precision)
	var target_y = round_vector3(target_basis.y, precision)
	var target_z = round_vector3(target_basis.z, precision)
	if axis == Vector3.UP:
		base_y = Vector3.ZERO
		target_y = Vector3.ZERO
	elif axis == Vector3.RIGHT:
		base_x = Vector3.ZERO
		target_x = Vector3.ZERO
	elif axis == Vector3.FORWARD:
		base_z = Vector3.ZERO
		target_z = Vector3.ZERO
	
	var result = false
	if base_x == target_x and base_y == target_y and base_z == target_z:
		result = true
	
	return result
	
	
func round_vector3(vector, precision):
	var result = Vector3(
		round(vector.x / precision) * precision,
		round(vector.y / precision) * precision,
		round(vector.z / precision) * precision
	)
	return result


func set_destination(new_destination):
	reset_destination()
	destination = new_destination
	print(transform.origin)
	print(destination)


func reset_destination():
	destination = null
	last_distance_to_destination = 0
	last_angle_to_destination = 0
