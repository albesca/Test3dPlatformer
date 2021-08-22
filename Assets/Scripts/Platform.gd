extends StaticBody


signal set_destination(destination_position)


func set_destination(_camera, event, click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
			and event.pressed:
		emit_signal("set_destination", to_global(click_position))
