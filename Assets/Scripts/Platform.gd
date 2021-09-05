extends StaticBody


signal set_destination(destination_position)
export var see_through = false


func set_destination(_camera, event, click_position, click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if Global.round_vector3(click_normal) == Vector3.UP:
			emit_signal("set_destination", click_position)
		else:
			print("I've been clicked from the sides or the bottom...")


func _physics_process(_delta):
	if see_through:
		$CSGBox.material.flags_transparent = true
		$CSGBox.material.albedo_color.a = 0.5
		input_ray_pickable = false
		see_through = false
	else:
		$CSGBox.material.flags_transparent = false
		$CSGBox.material.albedo_color.a = 1.0
		input_ray_pickable = true
