extends Node


const DEFAULT_PRECISION = 0.01
const MIN_ROTATING_SPEED = 0.25
const WORLD_FLOOR = -20.0
const DRAG_FACTOR = 100.0
const FALL_THRESHOLD = -0.5
const GRAVITY_FACTOR = 10.0
const FALL_FACTOR = 4.0
const OBJECT_PICKED = "object picked"
const SWITCHES_STATE = "switches state"
const SWITCHES_LIST = "switches list"
const OBJECTIVE_TYPE = "objective type"
const OBJECT_TYPE = "object type"
const OBJECTS_LIST = "objects list"
const OBJECT_MIN_QUANTITY = "object min quantity"
const MAX_SLOPE = PI/3
const STATE_ON_GROUND = "state on ground"
const STATE_FALLING = "state falling"
const STATE_JUMPING = "state jumping"

var rn_generator


func init_rng(rng_seed):
	rn_generator = RandomNumberGenerator.new()
	rn_generator.seed = rng_seed


func round_vector3(vector, precision = DEFAULT_PRECISION):
	var result = Vector3(
		round(vector.x / precision) * precision,
		round(vector.y / precision) * precision,
		round(vector.z / precision) * precision
	)
	return result


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
	
	
func get_level_state():
	var level_state = {}
	level_state[OBJECT_PICKED] = {
		OBJECTIVE_TYPE: OBJECT_MIN_QUANTITY,
		OBJECTS_LIST: {}
	}
	level_state[SWITCHES_STATE] = {
		OBJECTIVE_TYPE: SWITCHES_STATE,
		SWITCHES_LIST: {}
	}
	return level_state
