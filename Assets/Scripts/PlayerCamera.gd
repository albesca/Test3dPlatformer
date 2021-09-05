extends Camera


var feet_obstruction
var head_obstruction


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
	if current:
		if !$RayCastFeet.enabled:
			$RayCastFeet.set_deferred("enabled", true)
		if !$RayCastHead.enabled:
			$RayCastHead.set_deferred("enabled", true)
	else:
		if $RayCastFeet.enabled:
			$RayCastFeet.set_deferred("enabled", false)
		if $RayCastHead.enabled:
			$RayCastHead.set_deferred("enabled", false)
		
	if $RayCastFeet.is_colliding():
		$RayCastFeet.get_collider().see_through = true

	if $RayCastHead.is_colliding():
		$RayCastHead.get_collider().see_through = true
