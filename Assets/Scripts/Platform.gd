extends StaticBody


signal set_destination(destination_position)


func set_destination(_camera, event, click_position, click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		if Global.round_vector3(click_normal) == Vector3.UP:
			emit_signal("set_destination", click_position)
		else:
			print("I've been clicked from the sides or the bottom...")
