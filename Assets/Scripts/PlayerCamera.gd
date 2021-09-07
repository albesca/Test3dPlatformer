extends Camera


var feet_obstruction
var head_obstruction
var raycast_active = false
var obstructing_objects = []
var current_camera
export var camera_name = "default"


func set_raycasts(player_head_position, player_feet_position):
	var ray_rotation = transform.basis.get_rotation_quat()
	var cast_target_feet = global_transform.origin.direction_to(\
			player_feet_position)
	cast_target_feet = ray_rotation.inverse().xform(cast_target_feet)
	cast_target_feet = cast_target_feet * global_transform.origin.distance_to(\
			player_feet_position)
	$RayCastFeet.cast_to = cast_target_feet
	var cast_target_head = global_transform.origin.direction_to(\
			player_head_position)
	cast_target_head = ray_rotation.inverse().xform(cast_target_head)
	cast_target_head = cast_target_head * global_transform.origin.distance_to(\
			player_head_position)
	$RayCastHead.cast_to = cast_target_head


func _physics_process(_delta):
	var new_obstructing_objects = []
	if current_camera and raycast_active:
		if !$RayCastFeet.enabled:
			$RayCastFeet.set_deferred("enabled", true)
		if !$RayCastHead.enabled:
			$RayCastHead.set_deferred("enabled", true)

		if $RayCastFeet.is_colliding():
			new_obstructing_objects.append($RayCastFeet.get_collider())
			#$RayCastFeet.get_collider().see_through = true

		if $RayCastHead.is_colliding():
			if !$RayCastHead.get_collider() in new_obstructing_objects:
				new_obstructing_objects.append($RayCastHead.get_collider())
				#print("object intersects only head ray")
			#else:
			#	print("object also intersects feet ray")
			#$RayCastHead.get_collider().see_through = true
		
		for new_obstruction in new_obstructing_objects:
			new_obstruction.see_through = true
			var obs_index = obstructing_objects.find(new_obstruction)
			if obs_index > -1:
				obstructing_objects.remove(obs_index)

	else:
		if $RayCastFeet.enabled:
			$RayCastFeet.set_deferred("enabled", false)
		if $RayCastHead.enabled:
			$RayCastHead.set_deferred("enabled", false)

	for old_obstruction in obstructing_objects:
		old_obstruction.see_through = false

	obstructing_objects = new_obstructing_objects


func make_current():
	print(camera_name + " turning on")
	current_camera = true
	current = true
	

func make_not_current():
	print(camera_name + " turning off")
	current_camera = false
